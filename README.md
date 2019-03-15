[![pipeline status](https://gitlab.aristanetworks.com/tgrimonet/ansible-content/badges/master/pipeline.svg)](https://gitlab.aristanetworks.com/tgrimonet/ansible-content/commits/master)

<!-- START doctoc generated TOC please keep comment here to allow auto update -->
<!-- DON'T EDIT THIS SECTION, INSTEAD RE-RUN doctoc TO UPDATE -->
**Table of Contents**

- [About Ansible modules for Arista EOS automation](#about-ansible-modules-for-arista-eos-automation)
- [Repository structure](#repository-structure)
- [Requirements](#requirements)
    - [Docker and docker-topo](#docker-and-docker-topo)
    - [Get cEOS-LAB image](#get-ceos-lab-image)
    - [Install requirements](#install-requirements)
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
- Jinja2 & YML structures: [templating engine](docs/JINJA_YAML_STRUCTURES.md)


## Requirements

Repository requires to install some requirements to be consumed:

- Docker daemon
- [`docker-topo`](https://github.com/networkop/docker-topo) script
- cEOS-LAB image
- ansible software

In the meantime, it is recommended to run this repository in a virtual-environment. To start such environment, use following commands:

```shell
$ python3 -m pip install virtualenv
$ python3 -m virtualenv ansible_training
$ cd ansible_training
$ source bin/activate
```

### Docker and docker-topo

Docker installation is platform specific and you should use following links:

- [macOS installation](https://docs.docker.com/docker-for-mac/install/)
- [Ubuntu installation](https://docs.docker.com/install/linux/docker-ce/ubuntu/)
- [Centos installation](https://docs.docker.com/install/linux/docker-ce/centos/)

Then, install [`docker-topo`](https://github.com/networkop/docker-topo) from `pip`:

```shell
$ python3 -m pip install git+https://github.com/networkop/docker-topo.git
```

### Get cEOS-LAB image

With your Arista login, go to download page and download cEOS-LAB image on your laptop. Then, add ceos images to docker:

```shell
$ docker import cEOS-lab.tar.xz ceosimage:latest
```

### Install requirements

Install ansible with `pip`:

```shell
$ pip install -r requirements.txt
```

Then, check ansible version:

```
$ ansible --version
ansible 2.7.8
  config file = /Users/tgrimonet/Projects/ansible-demo/ansible.cfg
  configured module search path = ['/Users/tgrimonet/.ansible/plugins/modules', '/usr/share/ansible/plugins/modules']
  ansible python module location = /Users/tgrimonet/.venv/ansible-demo/lib/python3.7/site-packages/ansible
  executable location = /Users/tgrimonet/.venv/ansible-demo/bin/ansible
  python version = 3.7.2 (default, Jan 13 2019, 12:50:01) [Clang 10.0.0 (clang-1000.11.45.5)]
```

## Ask question or report issue

Please open an issue on Github this is the fastest way to get an answer.

## Contribute

Contributing pull requests are gladly welcomed for this repository. If you are planning a big change, please start a discussion first to make sure we'll be able to merge it.

## License

Project is published under [BSD License](LICENSE).
