#!/usr/bin/env python3
import os
import re
import logging
import argparse


def exact_version_in_develop_branch(commit_ref_name):
    branch_name_re = re.match(r'develop-(\d+)\.(\d+)', commit_ref_name)
    if branch_name_re is None:
        return None

    major_version = int(branch_name_re.group(1))
    minor_version = int(branch_name_re.group(2))

    logging.debug('in develop branch: %s, major_version: %d, minor_version: %d'
                  % (commit_ref_name, major_version, minor_version))

    return major_version, minor_version


def exact_version_in_release_branch(commit_ref_name):
    branch_name_re = re.match(r'release-(\d+)\.(\d+)', commit_ref_name)
    if branch_name_re is None:
        return None

    major_version = int(branch_name_re.group(1))
    minor_version = int(branch_name_re.group(2))

    logging.debug('in release branch: %s, major_version: %d, minor_version: %d'
                  % (commit_ref_name, major_version, minor_version))

    return major_version, minor_version


def exact_version_in_tag(commit_ref_name):
    tag_name_re = re.match(r'v(\d+)\.(\d+)\.(\d+)', commit_ref_name)
    if tag_name_re is None:
        return None

    major_version = int(tag_name_re.group(1))
    minor_version = int(tag_name_re.group(2))
    patch_version = int(tag_name_re.group(3))

    logging.debug('in release tag: %s, major_version: %d, minor_version: %d, patch_version:%d'
                  % (commit_ref_name, major_version, minor_version, patch_version))

    return major_version, minor_version, patch_version


def main():
    logging.basicConfig(level=logging.DEBUG)

    parser = argparse.ArgumentParser(
        description='RPP upload tools - repository')

    parser.add_argument('project', help='project name')
    parser.add_argument('commit', help='commit-ref')
    args = parser.parse_args()

    project_name = args.project
    commit_ref_name = args.commit

    logging.info('project_name: %s, commit_ref_name: %s' %
                 (project_name, commit_ref_name))

    version = exact_version_in_develop_branch(commit_ref_name)
    if version:
        print('%s-%d.%d-testing' % (project_name, version[0], version[1]))

    version = exact_version_in_tag(commit_ref_name)
    if version:
        print('%s-%d.%d-stable' % (project_name, version[0], version[1]))


if __name__ == '__main__':
    main()
