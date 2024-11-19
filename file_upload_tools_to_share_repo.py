
import logging
import argparse
import os
import sys
import pycurl
from io import BytesIO
from tqdm import tqdm

REPO_SERVER_URL_BASE = "https://repo.geedge.net/maintain/"

def upload_file(url, file_path):
    buffer = BytesIO()
    c = pycurl.Curl()
    file_size = os.path.getsize(file_path)
    progress_bar = tqdm(total=file_size, unit='B', unit_scale=True, desc='Uploading')
    def xferinfo(download_t, download_d, upload_t, upload_d):
        progress_bar.update(int(upload_d - progress_bar.n))
    try:
        c.setopt(c.URL, url)
        c.setopt(c.HTTPPOST, [("file", (c.FORM_FILE, file_path))])
        c.setopt(c.WRITEDATA, buffer)
        c.setopt(c.NETRC, c.NETRC_OPTIONAL)
        c.setopt(c.XFERINFOFUNCTION, xferinfo)
        c.setopt(c.NOPROGRESS, False)
        c.perform()
        response_code = c.getinfo(c.RESPONSE_CODE)
        buffer.seek(0)
        response_data = buffer.read()

        print(f"Response code: {response_code}.")
        print(f"Response data: {response_data.decode()}")
        if response_code != 200:
            print(f"Error: Response code is {response_code}. Exiting...")
            sys.exit(1)

    except Exception as e:
        print(f"Error info: {e}")
    finally:
        c.close()


def main():
    parser = argparse.ArgumentParser(description='FILE upload helper')
    parser.add_argument('repopath', type=str)
    parser.add_argument('package', type=str, nargs='+')
    parser.add_argument('--repo-server-url', type=str)
    parser.add_argument('--verbose', default=False, action='store_true')
    args = parser.parse_args()

    if (args.verbose):
        logging.basicConfig(level=logging.DEBUG)

    repopath = args.repopath
    package = args.package

    logging.info('repopath: %s' % repopath)
    logging.info('package: %s' % package)

    if args.repo_server_url:
        global REPO_SERVER_URL_BASE
        REPO_SERVER_URL_BASE = args.repo_server_url

    package_list = []
    for package in args.package:
        if os.path.isfile(package):
            package_list.append(package)
            continue

        for file in os.listdir(package):
            path = os.path.join(package, file)
            if os.path.isfile(path):
                package_list.append(path)

    logging.info('FILES: %s', str(package_list))

    post_url = REPO_SERVER_URL_BASE + repopath
    for package_path in package_list:
        upload_file(post_url, package_path)


if __name__ == "__main__":
    main()
