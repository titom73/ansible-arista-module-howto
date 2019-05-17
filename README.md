[![Documentation Status](https://readthedocs.org/projects/ansible-arista-howto/badge/?version=latest)](https://ansible-arista-howto.readthedocs.io/en/latest/?badge=latest)  [![Build Status](https://travis-ci.org/titom73/ansible-arista-module-howto.svg?branch=master)](https://travis-ci.org/titom73/ansible-arista-module-howto)



<!-- START doctoc generated TOC please keep comment here to allow auto update -->
<!-- DON'T EDIT THIS SECTION, INSTEAD RE-RUN doctoc TO UPDATE -->
**Table of Contents**

- [Ansible automation for Arista EOS devices](#ansible-automation-for-arista-eos-devices)
    - [About Ansible modules for Arista EOS automation](#about-ansible-modules-for-arista-eos-automation)
    - [Repository structure](#repository-structure)
    - [Installation & Requirements](#installation-&-requirements)
    - [Ask question or report issue](#ask-question-or-report-issue)
    - [Contribute](#contribute)
    - [License](#license)

<!-- END doctoc generated TOC please keep comment here to allow auto update -->

# Ansible automation for Arista EOS devices

This project provides some ready-to-use Ansible playbooks to interact with Arista EOS devices.

This repository comes with docker topology to execute content:
- 2 cEOS-LAB instances
- [`docker-topo`](https://github.com/networkop/docker-topo) to build docker topoogy
- ansible with [arista core modules](https://docs.ansible.com/ansible/latest/modules/list_of_network_modules.html#eos)

## About Ansible modules for Arista EOS automation

Arista EOS modules are part of the core modules list of ansible and do not require any additional 3rd part modules to be installed on your server. They are maintained by [Ansible Network Team](https://docs.ansible.com/ansible/latest/user_guide/modules_support.html#modules-support) and provides options to manage configuration and get status as well.

A complete list of available eos module is available on [Ansible documentation website](https://docs.ansible.com/ansible/latest/modules/list_of_network_modules.html#eos)


## Repository structure

> Do not forget to install requirements if you want to run tests

- All __ansible__ content is under [`ansible-content`](ansible-content) folder.
- All __HOW-TOs__ are under [`docs`](docs) folder

__List of documents__:

- Manage eos configuration with ansible: [EOS_CONFIG](docs/EOS_CONFIG.md)
- Getting status of Arista devices with Ansible: [EOS_COMMAND](docs/COLLECTING_STATUS.md)
- Jinja2 & YML structures: [templating engine](docs/JINJA_YAML_STRUCTURES.md)

For complete documentation, please refer to [read the doc](https://ansible-arista-howto.readthedocs.io/en/latest/) page.

## Installation & Requirements

Please refer to [installation](docs/INSTALL.md) before running content of this repository

## Ask question or report issue

Please open an issue on Github this is the fastest way to get an answer.

## Contribute

Contributing pull requests are gladly welcomed for this repository. If you are planning a big change, please start a discussion first to make sure we'll be able to merge it.

## License

Project is published under [BSD License](LICENSE).
