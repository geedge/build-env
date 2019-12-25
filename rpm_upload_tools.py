import requests
import urllib
import json
import time
import logging

PULP_SERVER_URL_BASE = "http://repo.internal.geedge.net/"
PULP_REPO_HREF = ""
PULP_DIST_HREF = ""


def orphans_cleanup():
    api_cleanup = urllib.parse.urljoin(
        PULP_SERVER_URL_BASE, '/pulp/api/v3/orphans/')

    r = requests.delete(api_cleanup)
    r.raise_for_status()


def wait_until_task_finished(task_url):
    api_task_url = urllib.parse.urljoin(PULP_SERVER_URL_BASE, task_url)
    while True:
        r = requests.get(api_task_url)
        r.raise_for_status()
        state = r.json()['state']

        if state == 'failed' or state == 'cancelled':
            raise Exception("task is cancelled", task_url, state)
        if state == 'completed':
            break

        # wait for task to complete
        time.sleep(1)
    return


def task_created_resource_by_task_url(task_url):
    r = requests.get(urllib.parse.urljoin(PULP_SERVER_URL_BASE, task_url))
    r.raise_for_status()
    return json.loads(r.text)['created_resources'][0]


def artifact_create(path):
    api_url_artifact = urllib.parse.urljoin(
        PULP_SERVER_URL_BASE, "/pulp/api/v3/artifacts/")
    with open(path, 'rb') as fp:
        files = {'file': fp}
        r = requests.post(api_url_artifact, files=files)
        r.raise_for_status()

    href = r.json()['pulp_href']
    href_url = urllib.parse.urljoin(PULP_SERVER_URL_BASE, href)
    requests.get(href_url).raise_for_status()
    return href


def content_create_from_artifact(artifact_href, pkgname):
    api_url_create_content = urllib.parse.urljoin(
        PULP_SERVER_URL_BASE, '/pulp/api/v3/content/rpm/packages/')
    r = requests.post(api_url_create_content, data={
                      'artifact': artifact_href, 'relative_path': pkgname})
    r.raise_for_status()

    task_href = r.json()['task']
    task_full_url = urllib.parse.urljoin(PULP_SERVER_URL_BASE, task_href)
    wait_until_task_finished(task_full_url)

    r = requests.get(task_full_url)
    r.raise_for_status()

    package_href = json.loads(r.text)['created_resources'][0]
    r = requests.get(urllib.parse.urljoin(PULP_SERVER_URL_BASE, package_href))
    r.raise_for_status()
    return package_href


def add_content_to_repo(repo_href, package_hrefs):
    api_url_publish = urllib.parse.urljoin(
        PULP_SERVER_URL_BASE, repo_href + 'modify/')
    r = requests.post(api_url_publish, json={
                      'add_content_units': package_hrefs})
    r.raise_for_status()

    # create task and wait for it to complete
    task_href = r.json()['task']
    task_full_url = urllib.parse.urljoin(PULP_SERVER_URL_BASE, task_href)
    wait_until_task_finished(task_full_url)


def publication_repo(repo_href):
    api_url_publish = urllib.parse.urljoin(
        PULP_SERVER_URL_BASE, '/pulp/api/v3/publications/rpm/rpm/')

    r = requests.post(api_url_publish, json={'repository': repo_href})
    r.raise_for_status()

    # wait the task
    task_href = r.json()['task']
    task_full_url = urllib.parse.urljoin(PULP_SERVER_URL_BASE, task_href)
    wait_until_task_finished(task_full_url)

    # publication
    pub_href = task_created_resource_by_task_url(task_full_url)
    return pub_href


def distribution(pub_href, name, base_path):
    api_url = urllib.parse.urljoin(
        PULP_SERVER_URL_BASE, '/pulp/api/v3/distributions/rpm/rpm/')

    r = requests.put(
        api_url, json={'name': name, 'base_path': base_path, 'publication': pub_href})
    r.raise_for_status()

    # wait the task
    task_href = r.json()['task']
    task_full_url = urllib.parse.urljoin(PULP_SERVER_URL_BASE, task_href)
    wait_until_task_finished(task_full_url)


def update_distributation_pub(dist_href, pub_href):
    api_url = urllib.parse.urljoin(PULP_SERVER_URL_BASE, dist_href)
    r = requests.get(api_url)
    r.raise_for_status()

    dist_base_path = r.json()['base_path']
    dist_name = r.json()['name']

    logging.info('prepare to update dist, name: %s, base_path: %s' %
                 (dist_name, dist_base_path))

    r = requests.put(api_url, json={
                     'base_path': dist_base_path, 'name': dist_name, 'publication': pub_href})
    r.raise_for_status()

    # wait the task
    task_href = r.json()['task']
    task_full_url = urllib.parse.urljoin(PULP_SERVER_URL_BASE, task_href)
    wait_until_task_finished(task_full_url)

    logging.info('update dist successfully, %s', task_href)


def main():
    import argparse
    import os

    parser = argparse.ArgumentParser(description='Pulp3 RPM upload helper')
    parser.add_argument('repo_href', type=str)
    parser.add_argument('dist_href', type=str)
    parser.add_argument('package', type=str, nargs='+')
    parser.add_argument('--pulp-server-url', type=str)
    args = parser.parse_args()

    if args.pulp_server_url:
        global PULP_SERVER_URL_BASE
        PULP_SERVER_URL_BASE = args.pulp_server_url

    orphans_cleanup()
    package_href_collection = []
    for package_path in args.package:
        package_basename = os.path.basename(package_path)
        artifact_href = artifact_create(package_path)
        package_href = content_create_from_artifact(
            artifact_href, package_basename)
        package_href_collection.append(package_href)

    add_content_to_repo(args.repo_href, package_href_collection)
    pub_href = publication_repo(args.repo_href)
    update_distributation_pub(args.dist_href, pub_href)


if __name__ == "__main__":
    main()
