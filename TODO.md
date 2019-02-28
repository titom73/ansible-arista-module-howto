# Todos

Project's todo:

- Content to build authentication
- Content for collecting data from devices: Collecting commands / parsing result in Ansible or JSON syntax
	- `eos_command`
	- `eos_facts`

- Updating configuration on the fly:
	- `eos_*` to update interfaces / vrf / system / ...
	- `eos_command` to push lines of config

- Content to build templates:
	- Jinja2 basics example (wiki style)
	- role to generate content (`eos_config`)

- Publication mechanismes:
	- Direct push (diff / syntax-check / ... )
	- CVP deployment approach