#!/bin/sh
# Syntax check of the role, as CI runs it (needs ansible-core and the ansible.posix collection).
#
# tests/test.yml applies the role as a playbook would: meta, defaults, vars and tasks/main.yml.
# tasks/main.yml loads the other task files with include_tasks, which --syntax-check does not
# follow, so every file under tasks/ is also imported statically in a generated playbook.
set -eu

cd "$(dirname "$0")/.."

ansible-playbook -i tests/inventory tests/test.yml --syntax-check

# Inside tests/, so that the relative paths below resolve against the playbook's directory.
gen=tests/.syntax-check.yml
trap 'rm -f "$gen"' EXIT INT TERM
{
    echo '---'
    echo '- name: Every task file of the role'
    echo '  hosts: localhost'
    echo '  gather_facts: false'
    echo '  tasks:'
    find tasks -name '*.yml' | LC_ALL=C sort | while read -r f; do
        echo "    - name: Import $f"
        echo "      ansible.builtin.import_tasks: ../$f"
    done
} > "$gen"
ansible-playbook -i tests/inventory "$gen" --syntax-check
echo "syntax check: $(find tasks -name '*.yml' | wc -l | tr -d ' ') task files OK"
