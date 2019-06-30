# Configure Arista EOS with Ansible

[`eos_config`](https://docs.ansible.com/ansible/latest/modules/eos_config_module.html#eos-config-module) is a core module managed by Ansible network team. As this module is part of the core, there is no need to install additional Ansible module with `ansible-galaxy`

As `eos_*` modules are part of core engine, we can use ansible options to run tests and capture configuration changes when running playbooks:

- __`--check` option__: When ansible-playbook is executed with `--check` it will not make any changes on remote systems. Modules will report what changes they would have made rather than making them.
- __`--diff` option__: When this flag is supplied and the module supports this, Ansible will report back the changes made or, if used with --check, the changes that would have been made.

> These options are generally called __dry-run__ mode.

## Apply lines of configurations to devices.

__Example playbooks__: ['pb.config.lines.simple.yaml'](https://github.com/titom73/ansible-arista-module-howto/tree/master/ansible-content/pb.config.lines.simple.yaml)

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

In this playbook, we use an authentication provider for ARISTA products as described in the [home page](https://github.com/titom73/ansible-arista-module-howto/tree/master/README.md)

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

## Apply configuration file to device

When playing with jinja2 templates, it is easier to generate a file and then push it to devices instead of applying line by line.

`eos_config` support a mechanism to push a config files from your server to remote devices. This file can be either a plain text file or a JINJA2 template. In case of a template, rendering will be done first by ansible and then result will be applied on devices.

### Apply a config file

To apply a plain text config, following playbook should be used:

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
        src: inputs/generic-config.cfg
```

> Config file can be a complete Arista configuration or just a snippet of the configuration you want to update.

In this example, [__`inputs/generic-config.cfg`__](https://github.com/titom73/ansible-arista-module-howto/tree/master/ansible-content/inputs/generic-config.cfg) has following content:

```
interface Ethernet2
   description Description from generic configuration block
!
```

And running playbook [__`pb.config.file.yaml`__](https://github.com/titom73/ansible-arista-module-howto/tree/master/ansible-content/pb.config.file.yaml) with `--diff` option shows all changes:

```shell
$ ansible-playbook pb.config.file.yaml --diff

PLAY [Run commands on remote LAB devices] ********

TASK [include_vars] ********
ok: [ceos1]
ok: [ceos2]

TASK [Configure interface description] ********
--- system:/running-config
+++ session:/********_1551711841-session-config
@@ -13,6 +13,7 @@
 interface Ethernet1
 !
 interface Ethernet2
+   description Description from generic configuration block
 !
  no ip routing
 !

changed: [ceos2]
--- system:/running-config
+++ session:/********_1551711841-session-config
@@ -13,6 +13,7 @@
 interface Ethernet1
 !
 interface Ethernet2
+   description Description from generic configuration block
 !
 no ip routing
 !

changed: [ceos1]

PLAY RECAP ********
ceos1                      : ok=2    changed=1    unreachable=0    failed=0
ceos2                      : ok=2    changed=1    unreachable=0    failed=0
```

### Apply a template

`eos_config` also supports a JINJA2 template as an input file. In this scenario, ansible will run template rendering locally and then will push result to devices. It means that your configuration will have some content specific per device and / or collected in a previous task.

> This section will not describe JINJA2 syntax. A specific page is available with some hints about jinja2 syntax and YAML structures.

Following template creates a basic SNMP configuration with generic fields. Only thing is `chassis-id` will be set with `inventory_hostname` defined in our [`inventory.ini`](https://github.com/titom73/ansible-arista-module-howto/tree/master/ansible-content/inventory.ini) file.

```jinja2
snmp-server chassis-id {{inventory_hostname}}
snmp-server contact demo@acme.com
snmp-server location "cEOS Virtual lab"
```

Playbook is very close to playbook in [_Apply a config file_](#apply-a-config-file)

```yaml
---
- name: Run commands on remote LAB devices
  hosts: all
  connection: local
  gather_facts: no
  pre_tasks:
    - include_vars: "authentication.yaml"

  tasks:
    - name: Configure SNMP information with template
      eos_config:
        provider: "{{arista_credentials}}"
        src: "inputs/template-config.j2"
```

The main difference is `src` field where you put a template file instead of a plan text configuration.

As you can see in extract below, content is built on a per device approach:

```shell
$ ansible-playbook pb.config.template.yaml --diff

PLAY [Run commands on remote LAB devices] ********

TASK [include_vars] ********
ok: [ceos1]
ok: [ceos2]

TASK [Configure SNMP information with template] ********
--- system:/running-config
+++ session:/********_1551713015-session-config
@@ -3,6 +3,10 @@
 transceiver qsfp default-mode 4x10G
 !
 hostname ceos1
+!
+snmp-server chassis-id ceos1
+snmp-  server contact demo@acme.com
+snmp-server location "cEOS Virtual lab"
 !
 spanning-tree mode mstp
 !

changed: [ceos1]
--- system:/running-config
+++ session:/********_1551713015-session-config
@@ -3,6 +3,10 @@
 transceiver qsfp default-mode 4x10G
 !
 hostname ceos2
+!
+snmp-server chassis-id ceos2
+snmp-server contact demo@acme.com
+snmp-server location "cEOS Virtual lab"
 !
 spanning-tree mode mstp
 !

changed: [ceos2]

PLAY RECAP ********
ceos1                      : ok=2    changed=1    unreachable=0    failed=0
ceos2                      : ok=2    changed=1    unreachable=0    failed=0
```

## Intended configuration approach

Pushing intended configuration is probably the best approach in an automation workflow: your device configuration does not deviate from your expectations as complete configuration is pushed by ansible.

To work in this approach, you need to build complete configuration using either a complete template or by assembling rendered templates. Once it is done, you can push and replace configuration with following syntax:

 ```yaml
   tasks:
    - name: Load a config in an intended way
      eos_config:
        provider: "{{arista_credentials}}"
        src: "{{ lookup('file', 'inputs/{{inventory_hostname}}-master.cfg') }}"
        replace: 'config'
 ```

This approach can also be applied with template:

```yaml
  tasks:
    - name: Intended configuration management
      eos_config:
        provider: "{{arista_credentials}}"
        src: "device-configuration.j2"
        replace: "config"
```

## And finally, how to save config

`eos_config` module can automatically save config to the __startup_config__. It provides 3 different options to do that. The `save` action is started by either __save__ or __save_when__ keywords:

- __save__: automatically save the running-config to startup-config after any execution of the task.
- __save_when__: gives an option to select when ansible save running-config to startup-config:
  - `always`: Equal to __save__ keyword
  - `modified`: The running-config will only be copied to the startup-config if it has changed since the last save to startup-config
  - `changed`: (ansible >= 2.5) The running-config will only be copied to the startup-config if the task has made a change
  - `never`: Well, running will never be copied to startup-config. Can be useful for validation purpose

So the last playbook should be like this one:

```yaml
---
- name: Run commands on remote LAB devices
  hosts: all
  connection: local
  gather_facts: no
  pre_tasks:
    - include_vars: "authentication.yaml"

  tasks:
    - name: Configure SNMP information with template
      eos_config:
        provider: "{{arista_credentials}}"
        src: "inputs/template-config.j2"
        save_when: changed
```

## Get diff between running and intended configuration

In cas we generate complete configuration, it is nice to capture the deviation between our target (generated configuration) and running configuration on devices.

So to do that, `eos_config` has a special option named `diff_against: intended` and then we defined what we named __intended__ configuration.

```yaml
---
- name: Run commands on remote LAB devices
  hosts: ceos1
  connection: local
  gather_facts: no
  pre_tasks:
    - include_vars: "authentication.yaml"

  tasks:
    - name: diff the running config against a master config
      eos_config:
        provider: "{{arista_credentials}}"
        diff_against: intended
        intended_config: "{{ lookup('file', 'inputs/{{inventory_hostname}}-master.cfg') }}"
```

Output of the [__pb.config.intended.yaml__](https://github.com/titom73/ansible-arista-module-howto/tree/master/ansible-content/pb.config.intended.yaml) playbook is the following:

```shell
$ ansible-playbook pb.configure.intended.yaml --check --diff

PLAY [Run commands on remote LAB devices] ********

TASK [include_vars] ********
ok: [ceos1]

TASK [diff the running config against a master config] ********
--- before
+++ after
@@ -1,16 +1,10 @@
 transceiver qsfp default-mode 4x10G
-hostname ceos1
-snmp-server chassis-id ceos1
-snmp-server contact demo@acme.com
-snmp-server location "cEOS Virtual lab"
+hostname CEOS1-TEST
 spanning-tree mode mstp
 no aaa root
 username ******** privilege 15 secret sha512 $6$j80NtRkV0CMlgXPS$a0.JbwuO1NMvIthS4eu6dEMHIV9gNGRRFf5SI6qNu5g4I3zxinnVrSMyj8EkQ1V/x7ORAWwe5CpYmgQME2jad1
 interface Ethernet1
 interface Ethernet2
-   description My Wonderful description
-   switchport trunk allowed vlan 12
-   switchport mode trunk
 no ip routing
 management api http-commands
    no shutdown

changed: [ceos1]

PLAY RECAP ********
ceos1                      : ok=2    changed=1    unreachable=0    failed=0
```

As you can see, we have a complete view of the configuration deviation between running and intended.

> Note: this module requires to be run with --check flag.

