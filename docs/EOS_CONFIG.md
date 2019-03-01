# eos_config to manage Arista EOS configuration

[`eos_config`](https://docs.ansible.com/ansible/latest/modules/eos_config_module.html#eos-config-module) is a core module managed by Ansible network team. As this module is part of the core, there is no need to install additional Ansible module with `ansible-galaxy`

As `eos_*` modules are part of core engine, we can use ansible options to run tests and capture configuration changes when running playbooks:

- __`--check` option__: When ansible-playbook is executed with `--check` it will not make any changes on remote systems. Modules will report what changes they would have made rather than making them.
- __`--diff` option__: When this flag is supplied and the module supports this, Ansible will report back the changes made or, if used with --check, the changes that would have been made.

> These options are generally called __dry-run__ mode.

## Apply lines of configurations to devices.

__Example playbooks__: ['pb.config.lines.simple.yaml'](../pb.config.lines.simple.yaml)

### Basic lines of configuration

To push lines of configuraiton to device, a small playbook should be like this:

```yaml
---
- name: Run commands on remote LAB devices
  hosts: all
  connection: local
  gather_facts: no
  pre_tasks:
    - include_vars: "authentication.yaml"

  tasks:
    - name: Configure device hostname from lines
      eos_config:
        provider: "{{arista_credentials}}"
        lines: 
          - "hostname MyHostname"
          - "ntp server 1.1.1.1"
```

In this playbook, we use an authentication provider for ARISTA products as described in the [home page](../README.md)

When applying this playbook, output is like below:

> using `--diff` option display changes applied by tasks

```shell
$ ansible-playbook pb.config.lines.simple.yaml --diff

PLAY [Run commands on remote LAB devices] ********

TASK [include_vars] ********
ok: [ceos1]
ok: [ceos2]

TASK [Configure device hostname from lines] ********
--- system:/running-config
+++ session:/********_1551450161-session-config
@@ -2,7 +2,9 @@
 !
 transceiver qsfp default-mode 4x10G
 !
-hostname CEOS2
+hostname MyHostname
+!
+ntp server 1.1.1.1
 !
 spanning-tree mode mstp
 !

changed: [ceos2]
--- system:/running-config
+++ session:/********_1551450161-session-config
@@ -2,7 +2,7 @@
 !
 transceiver qsfp default-mode 4x10G
 !
-hostname CEOS1
+hostname MyHostname
 !
 ntp server 1.1.1.1
 !

changed: [ceos1]

PLAY RECAP ********
ceos1                      : ok=2    changed=1    unreachable=0    failed=0
ceos2                      : ok=2    changed=1    unreachable=0    failed=0
```

### Dynamic lines of configuration

Even if it is not the easiest way to play with, you can include Jinja2 variables in your configuration lines. These Jinja2 variables shall be defined previously in your `host_vars` and / or `group_vars`

```yaml
---
- name: Run commands on remote LAB devices
  hosts: all
  connection: local
  gather_facts: no
  pre_tasks:
    - include_vars: "authentication.yaml"

  tasks:
    - name: Configure device hostname from lines
      eos_config:
        provider: "{{arista_credentials}}"
        lines: 
          - "hostname {{inventory_hostname}}-ansible"
          - "ntp server 1.1.1.1"
```

Below is output of a change when running this specific playbooK with `--diff`

```shell
TASK [Configure device hostname from lines] ********
--- system:/running-config
+++ session:/********_1551450491-session-config
@@ -2,7 +2,7 @@
 !
 transceiver qsfp default-mode 4x10G
 !
-hostname MyHostname
+hostname ceos2-automation
 !
 ntp server 1.1.1.1
 !
```

### Lines of configuration within a block

Assuming we want to configure an interface, we have to first enter to this block and then push configuration like this:

Arista interace configuration:

```
!
interface Ethernet 1
  description My Wonderful description
!
```

To achieve this configuration with ansible module, syntax should be like this:

```yaml
---
- name: Run commands on remote LAB devices
  hosts: all
  connection: local
  gather_facts: no
  pre_tasks:
    - include_vars: "authentication.yaml"

  tasks:
    - name: Configure interface description
      eos_config:
        provider: "{{arista_credentials}}"
        lines: 
          - description My Wonderful description
        parents: interface Ethernet 1
        replace: block
```

With a `--diff`, we can that description is applied to interface `Ethernet 1`

```
[...]
changed: [ceos1]
--- system:/running-config
+++ session:/********_1551451836-session-config
@@ -13,6 +13,7 @@
 !
 interface Ethernet1
+   description My Wonderful description
 !
 interface Ethernet2
 !
[...]
PLAY RECAP ***
ceos1                      : ok=4    changed=1    unreachable=0    failed=0
ceos2                      : ok=4    changed=1    unreachable=0    failed=0
```

And the result is quite simple:

```
ceos1-automation#show interfaces description
Interface      Status         Protocol    Description
Et1            up             up          My Wonderful description
Et2            up             up
```