import requests
import urllib
import json
import time
import logging
import argparse
import os
import subprocess
import hashlib
import shutil

REPO_SERVER_URL_BASE = "http://repo.internal.geedge.net/maintain/"

def upload_file_to_repo(repopath,path):
    api_url_artifact = urllib.parse.urljoin(
        REPO_SERVER_URL_BASE, repopath)
    with open(path, 'rb') as fp:
        files = {'file': fp}
        r = requests.post(api_url_artifact, files=files)
        r.raise_for_status()

    logging.debug("Response: %s", r.json())
    status = r.json()['success']
    if status == True:
        logging.fatal("Success to upload file %s to repo %s", path, repopath)
    else:
        logging.fatal("Fail to upload file %s to repo %s", path, repopath)

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

    for package_path in package_list:
        upload_file_to_repo(repopath,package_path)


if __name__ == "__main__":
    main()
