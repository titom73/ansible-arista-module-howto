# Collecting status from Arista EOS devices

Ansible provides 2 different modules to collect information from EOS devices:

- [`eos_facts`](https://docs.ansible.com/ansible/latest/modules/eos_facts_module.html#eos-facts-module): Collect facts from devices such has Hardware, EOS version, configuration.
- [`eos_command`](https://docs.ansible.com/ansible/latest/modules/eos_command_module.html#eos-command-module): Collect result of any command you send to a device.


## Collecting facts from devices.

This module collects all device facts from remote device. All keys found on device are prepend with `ansible_net_`. In addition of ](https://docs.ansible.com/ansible/latest/reference_appendices/common_return_values.html#common-return-values) collecting by Ansible, this module also collects following keys:

- All IPv4 addresses configured on the device
- All IPv6 addresses configured on the device
- The current active config from the device
- All file system names available on the device
- The fully qualified domain name of the device
- The list of fact subsets collected from the device
- The configured hostname of the device
- The image file the device is running
- A hash of all interfaces running on the system
- The available free memory on the remote device in Mb
- The total memory on the remote device in Mb
- The model name returned from the device
- The list of LLDP neighbors from the remote device
- The serial number of the remote device
- The operating system version running on the remote device

### Collect all facts and display some variables

Below is a [playbook example](https://github.com/titom73/ansible-arista-module-howto/tree/master/ansible-content/pb.collect.facts.yaml) that grab all facts, register them into a variable named `facts` and then display output

```yaml
---
- name: Run commands on remote LAB devices
  hosts: lab
  connection: network_cli
  gather_facts: false
  pre_tasks:
    - include_vars: "authentication.yaml"

  tasks:
    - name: Collect all facts from device
      eos_facts:
        provider: "{{arista_credentials}}"
        gather_subset:
          - all
      register: facts

    - name: Display result
      debug:
        msg: "Model is {{facts.ansible_facts.ansible_net_model}} and it is running {{facts.ansible_facts.ansible_net_version}}"
```

Output of this playbook is quite easy to:

```shell
$ ansible-playbook pb.get.commands.yaml --limit ceos1
[...]
TASK [Display result] ********
ok: [ceos01] => {
    "msg": "Model is cEOS and it is running 4.21.1.1F"
}
[...]
```

### Save device configuration from facts

To save configuration, we can collect only configuration fact from device and save output to a file like in [playbook](https://github.com/titom73/ansible-arista-module-howto/tree/master/ansible-content/pb.collect.facts.config.yaml) below:

```yaml
---
- name: Run commands on remote LAB devices
  hosts: all
  connection: local
  gather_facts: false
  pre_tasks:
    - include_vars: "authentication.yaml"

  tasks:
    - name: Create output directory (if missing)
      file:
        path: "{{playbook_dir}}/config"
        state: directory

    - name: Collect all facts from device
      eos_facts:
        provider: "{{arista_credentials}}"
        gather_subset:
          - config
      register: facts

    - name: copy collected configuration in configuration/text directory
      copy:
        content: "{{ facts.ansible_facts.ansible_net_config }}"
        dest: "{{ playbook_dir }}/config/{{ inventory_hostname }}.conf"
```

Playbook will create a folder named `config` if it is missing and then save config files:

```shell
$ ansible-playbook pb.get.commands.yaml

PLAY [Run commands on remote LAB devices] ********

TASK [include_vars] ********
ok: [ceos01]
ok: [ceos02]


TASK [Create output directory (if missing)] ********
ok: [ceos01]
ok: [ceos02]


TASK [Collect all facts from device] ********
ok: [ceos01]
ok: [ceos02]


TASK [copy collected configuration in configuration/text directory] ********
changed: [ceos01]
changed: [ceos02]

PLAY RECAP ********
ceos01                     : ok=4    changed=1    unreachable=0    failed=0
ceos02                     : ok=4    changed=1    unreachable=0    failed=0
```

And from your shell perspective:

```shell
$ tree -L 2
.
├── ansible.cfg
├── authentication.yaml
├── config
│   ├── ceos1.conf
│   └── ceos2.conf
├── group_vars
├── host_vars
│   ├── ceos1
│   └── ceos2
```

## Collecting result of commands

### Collect full command result:

Another module to collect status of EOS devices is `eos_command` module. It gives you a method to run commandon any Arista device and save result for further tasks.

Next playbook will monitor status of BGP peers:

```yaml
---
- name: Run commands on remote LAB devices
  hosts: all
  connection: local
  gather_facts: false
  pre_tasks:
    - include_vars: "authentication.yaml"

  tasks:
    - name: Collect BGP Status
      eos_command:
        commands:
          - enable
          - show ip bgp summary
        provider: "{{arista_credentials}}"
      register: bgp_status

    - name: Display result
      debug:
        var: bgp_status

```

And the result is (truncated):

```shell
$ ansible-playbook pb.collect.status.bgp.yaml

PLAY [Run commands on remote LAB devices] ********

TASK [include_vars] ********
ok: [ceos1]
ok: [ceos2]

TASK [Collect BGP Status] ********
ok: [ceos2]
ok: [ceos1]

TASK [Display result] ********
ok: [ceos1] => {
    "bgp_status": {
        "changed": false,
        "failed": false,
        "stdout": [
            {},
            {
                "vrfs": {
                    "default": {
                        "asn": 65001,
[...]
PLAY RECAP ********
ceos1                      : ok=3    changed=0    unreachable=0    failed=0
ceos2                      : ok=3    changed=0    unreachable=0    failed=0

```

### Filter results using loop

Because Output is very verbose, we can reduce a bit to focus only on status of any configured peers by using [`with_dict`](https://docs.ansible.com/ansible/2.4/playbooks_loops.html#looping-over-hashes) loop management:

```yaml
---
- name: Run commands on remote LAB devices
  hosts: all
  connection: local
  gather_facts: false
  pre_tasks:
    - include_vars: "authentication.yaml"

  tasks:
    - name: Collect BGP Status
      eos_command:
        commands:
          - enable
          - show ip bgp summary
        provider: "{{arista_credentials}}"
      register: bgp_status

    - name: Display result
      debug:
        msg: "Peering with {{item.key}} is {{item.value.peerState}}"
      with_dict: "{{bgp_status.stdout[1].vrfs.default.peers}}"
```

And output is quite shorter than previous try:

```shell
$ ansible-playbook pb.collect.status.bgp.yaml

PLAY [Run commands on remote LAB devices] ********

TASK [include_vars] ********
ok: [ceos1]
ok: [ceos2]

TASK [Collect BGP Status] ********
ok: [ceos2]
ok: [ceos1]

TASK [Display result] ********
ok: [ceos1] => (item={'key': '10.0.0.2', 'value': {'msgSent': 33, 'inMsgQueue': 0, 'prefixReceived': 0, 'upDownTime': 1552640949.496501, 'version': 4, 'msgReceived': 32, 'prefixAccepted': 0, 'peerState': 'Established', 'outMsgQueue': 0, 'underMaintenance': False, 'asn': 65002}}) => {
    "msg": "Peering with 10.0.0.2 is Established"
}
ok: [ceos2] => (item={'key': '10.0.0.1', 'value': {'msgSent': 32, 'inMsgQueue': 0, 'prefixReceived': 0, 'upDownTime': 1552640948.972306, 'version': 4, 'msgReceived': 32, 'prefixAccepted': 0, 'peerState': 'Established', 'outMsgQueue': 0, 'underMaintenance': False, 'asn': 65001}}) => {
    "msg": "Peering with 10.0.0.1 is Established"
}

PLAY RECAP ********
ceos1                      : ok=3    changed=0    unreachable=0    failed=0
ceos2                      : ok=3    changed=0    unreachable=0    failed=0
```

### Wait for a specific result

Waiting for a specific result is useful to set a task to fail or success depending on a change propagating in the network.

In this example, we are going to put one device in [maintenance mode](https://www.arista.com/en/um-eos/eos-section-10-1-overview#ww1156633). To do that, we use a [playbook](https://github.com/titom73/ansible-arista-module-howto/tree/master/ansible-content/pb.collect.waitfor.maintenance.yaml) to configure device in maintenance mode using [`eos_config`](EOS_CONFIG.md) and then waiting for result of this change with command `show maintenance`

```yaml
---
- name: Run commands on remote LAB devices
  hosts: ceos1
  connection: local
  gather_facts: false
  pre_tasks:
    - include_vars: "authentication.yaml"

  tasks:
    - name: Configure device hostname from lines
      eos_config:
        provider: "{{arista_credentials}}"
        lines:
          - quiesce
        parents:
          - maintenance
          - unit System

    - name: Wait for device to change to maintenance mode (10sec)
      eos_command:
        provider: "{{arista_credentials}}"
        commands: show maintenance
        wait_for: result[0]['units']['System']['state'] eq 'underMaintenance'
        interval: 2
        retries: 5
```

In case of these 10 seconds (5 tries with 2 seconds in between) are not enough, then, task fails:

```shell
$ ansible-playbook pb.collect.waitfor.maintenance.yaml

PLAY [Run commands on remote LAB devices] ********

TASK [include_vars] ********
ok: [ceos1]

TASK [Configure device hostname from lines] ********
ok: [ceos1]

TASK [Wait for device to change to maintenance mode (10sec)] ********
fatal: [ceos1]: FAILED! => {"changed": false, "failed_conditions": ["result[0]['units']['System']['state'] eq 'underMaintenance'"], "msg": "One or more conditional statements have not been satisf
ied"}

PLAY RECAP ********
ceos1                      : ok=2    changed=0    unreachable=0    failed=1
```

But when device changes to `underMaintenance`, then, task is a success:

```shell
$ ansible-playbook pb.collect.waitfor.maintenance.yaml

PLAY [Run commands on remote LAB devices] ********

TASK [include_vars] ********
ok: [ceos1]

TASK [Configure device hostname from lines] ********
ok: [ceos1]

TASK [Wait for device to change to maintenance mode (10sec)] ********
ok: [ceos1]

PLAY RECAP ********
ceos1                      : ok=3    changed=0    unreachable=0    failed=0
```

