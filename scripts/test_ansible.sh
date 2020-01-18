#!/bin/bash
set -eu

# Fetch bash helpers and source it.
if [ ! -e .bash_helpers.sh ]; then
  curl -kSL https://raw.githubusercontent.com/13pgeiser/bash/master/bash_helpers.sh -o .bash_helpers.sh
fi
source ./.bash_helpers.sh
echo "Setup venv for ansible"
setup_virtual_env
PATH="$VENV:$PATH"
echo "Fetch roles with ansible-galaxy"
if [ ! -e roles ]; then
  mkdir -p "$SCRIPT_DIR/roles"
  ansible-galaxy install --roles-path roles "git+https://13pgeiser@github.com/13pgeiser/ansible_machine_demo.git"
fi
echo "Starting QEMU"
launch_qemu tcp::2222-:22 4G buster-standard.iso
echo "Waiting for SSH connection"
wait_for_ssh localadmin@localhost 2222
(
  echo "Launch ansible-playbook (ansible_machine_demo)"
	cd "$SCRIPT_DIR/roles" || exit
	ansible-playbook -i ../inventory "ansible_machine_demo/tasks/main.yml" -vv
)
echo "Calling shutdown!"
ssh -p 2222 localadmin@localhost "sudo poweroff" || true

