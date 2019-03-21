# Installation and Lab Environment

## Requirements

Repository requires to install some requirements to be consumed:

- Docker daemon
- [__docker-topo__](https://github.com/networkop/docker-topo) script
- cEOS-LAB image
- ansible software

In the meantime, it is recommended to run this repository in a virtual-environment. To start such environment, use following commands:

```shell
$ python3 -m pip install virtualenv
$ python3 -m virtualenv ansible_training
$ cd ansible_training
$ source bin/activate
```

## Docker and docker-topo

Docker installation is platform specific and you should use following links:

- [macOS installation](https://docs.docker.com/docker-for-mac/install/)
- [Ubuntu installation](https://docs.docker.com/install/linux/docker-ce/ubuntu/)
- [Centos installation](https://docs.docker.com/install/linux/docker-ce/centos/)

Then, install [`docker-topo`](https://github.com/networkop/docker-topo) from `pip`:

```shell
$ python3 -m pip install git+https://github.com/networkop/docker-topo.git
```

## Get cEOS-LAB image

With your Arista login, go to download page and download cEOS-LAB image on your laptop. Then, add ceos images to docker:

```shell
$ docker import cEOS-lab.tar.xz ceosimage:latest
```

## Run docker topology

Once docker-topo is installed, run the docker topology with following commands:

```shell
# Clone repository locally
$ git clone https://github.com/titom73/ansible-arista-module-howto.git

# Enter repository
$ cd ansible-arista-module-howto/

# Build docker topology
$ docker-topo --create ansible-demo-topology.yaml
```


## Install requirements

Install ansible with `pip`:

```shell
$ pip install -r requirements.txt
```

Then, check ansible version (version might have changed until we release this document):

```
$ ansible --version
ansible 2.7.8
  config file = /Users/tgrimonet/Projects/ansible-demo/ansible.cfg
  configured module search path = ['/Users/tgrimonet/.ansible/plugins/modules', '/usr/share/ansible/plugins/modules']
  ansible python module location = /Users/tgrimonet/.venv/ansible-demo/lib/python3.7/site-packages/ansible
  executable location = /Users/tgrimonet/.venv/ansible-demo/bin/ansible
  python version = 3.7.2 (default, Jan 13 2019, 12:50:01) [Clang 10.0.0 (clang-1000.11.45.5)]
```
