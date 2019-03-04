#!/bin/sh

echo 'Check ansible syntax for all playbooks'
for YAML_FILE in $(find . -name \*.yaml) ; do
	echo '  * Linting file '${YAML_FILE}
	yamllint -c .ci/yamllintrc ${YAML_FILE}
done
echo '\nEnd Syntax check validation\n'