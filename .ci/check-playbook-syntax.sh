#!/bin/sh

echo 'Check ansible syntax for all playbooks'
for PLAYBOOK in $(find . -name \pb.*.yaml) ; do
	echo '\n  * Syntax check for file '${PLAYBOOK}
	ansible-playbook -i ansible-content/inventory.ini ${PLAYBOOK} --syntax-check
done
echo '\nEnd Syntax check validation\n'