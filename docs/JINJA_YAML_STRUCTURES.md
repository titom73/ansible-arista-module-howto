# YAML Structures in Jinja2

Data structure to use `YAML` with `JINJA2` templates. `YAML` keeps data stored as a map containing keys and values associated to those keys.


## Basic

### Generic key allocation

`YAML` input data structure

```yaml
---
time_zone: Europe/Paris
hostname: myDevice
comment: “This device is a fake one”
```

`JINJA2` to consume `YAML` data structure 

```jinja2
{% if time_zone is defined %}
clock timezone  {{ time_zone }};
{% endif %}
```

### Structured key allocation

YAML will consider lines prefixed with more spaces than parent key are contained inside it

```yaml
---
routing_policy:
  communities:
    myCommunity: 99:1
    tenant2: 99:2
```

Data structure similar to this YAML representation is :

```python
routing_policy = {
    "communities": {
        "myCommunity": "99:1",
        "tenant2": "99:2"
    }
}
```

## List Management

### YAML List

Assuming following data structure in `YAML`

```yaml
---
ntp_servers:
  - 8.8.8.8
  - 4.4.4.4
```

Access data from JINJA2 can be done with the following code:

```jinja2
{% for ntp_server in ntp_servers %}
ntp server {{ ntp_server }};
{% endfor %}
```

Data structure similar to this YAML representation is :

```python
ntp_servers = ['8.8.8.8', '4.4.4.4']
```

### YAML Dictionary

Assuming following data structure in `YAML`

```yaml
---
vlans:
  10: descr1
  20: descr2
  30: descr3
```

Access data from JINJA2 can be done with the following code:

```jinja2
{% for vlan_id, descr in vlans.items() %}
vlan {{ vlan_id }}
  description {{ descr }}
{% endfor %}

```

Data structure similar to this YAML representation is :

```python
vlans = {10: "descr1", 20: "descr2", 30: "descr3"}
```

### YAML Maps

Assuming following data structure in `YAML`

```yaml
---
interfaces:
  - name: "ge-0/0/0"
    descr: "Blah"
  - name: "ge-0/0/1"
    descr: "comment"
```

Access data from JINJA2 can be done with the following code:

```jinja2
{% for interface in interfaces %}
interface {{interface.name}} {
   description {{interface.descr}};
{% endfor %}
```

Data structure similar to this YAML representation is :

```python
interfaces = [{"name": "ge-0/0/0", "descr": "Blah"},
             {"name": "ge-0/0/1", "descr": "comment"}]
```

## Advanced Jinja2 syntax

### Update variable in a Loop

Syntax below allows user to update value of a variable within a loop and access to it after in a different jinja2 block:

```
{% set ns = namespace (dev_state = "disable") %}

{% for portname, portlist in topo[inventory_hostname].iteritems() %}
  {% if portlist.state == "enable" %}
    {% set ns.dev_state = "enable" %}
  {% endif %}
{% endfor %}

status: {{ns.dev_state|default("enable")}}
```

### Use IPaddr within Jinja2 template

Assuming following `yaml` definition:

```yaml
id: 10
underlay:
  networks:
    loopbacks: 10.0.0.0/16

```

Jinja gives option to build IP address within `loopback` network with following syntax where `id` is the idth in the network:

```
loopback_ip: {{ underlay.networks.loopbacks | ipaddr(id) | ipaddr('address') }}
```

Another example:

`{{ tenant.interconnect_prefix | ipaddr(6)}}` combined with `interconnect_prefix: 172.25.10.16/28` resulst in `172.25.10.22`

### Manage Jinja2 rendering indentation

 Jinja2 can manage whitespace and tabular indentation with `lstrip_blocks` and `trim_blocks` options:

- `trim_blocks`: If this is set to `True` the first newline after a block is removed (block, not variable tag!). Defaults to `False`.
- `lstrip_blocks`: If this is set to `True` leading spaces and tabs are stripped from the start of a line to a block. Defaults to `False`.

To manage these options, just put this line in your template:

```
#jinja2: lstrip_blocks: "True (or False)", trim_blocks: "True (or False)"
...
```

__Example__

Using this template:

```
{% for host in groups['webservers'] %}
    {% if inventory_hostname in hostvars[host]['ansible_fqdn'] %}
{{ hostvars[host]['ansible_default_ipv4']['address'] }} {{ hostvars[host]['ansible_fqdn'] }} {{ hostvars[host]['inventory_hostname'] }} MYSELF
    {% else %}
{{ hostvars[host]['ansible_default_ipv4']['address'] }} {{ hostvars[host]['ansible_fqdn'] }} jcs-server{{ loop.index }} {{ hostvars[host]['inventory_hostname'] }}
    {% endif %}
{% endfor %}
```

_`lstrip_block=False`_

Rendering is similar to :

```
    172.16.25.1 spine1
               172.16.25.3 spine2
               172.16.25.4 spine3
```

_`lstrip_block=true`_

Rendering should be:

```
172.16.25.1 spine1
172.16.25.3 spine2
172.16.25.4 spine3
```

### Loop management

Jinja2 has built-in option to manage loop information:


`loop.index`: The current iteration of the loop. (1 indexed)
`loop.index0`: The current iteration of the loop. (0 indexed)
`loop.revindex`: The number of iterations from the end of the loop (1 indexed)
`loop.revindex0`: The number of iterations from the end of the loop (0 indexed)
`loop.first`: True if first iteration.
`loop.last`: True if last iteration.
`loop.length`: The number of items in the sequence.
`loop.cycle`: A helper function to cycle between a list of sequences. See the explanation below.
`loop.depth`: Indicates how deep in deep in a recursive loop the rendering currently is. Starts at level 1
`loop.depth0`: Indicates how deep in deep in a recursive loop the rendering currently is. Starts at level 0
