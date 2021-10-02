#!/bin/bash
set -eu

source ./bash-helpers/helpers.sh

echo "Setup venv for ansible"
setup_virtual_env
PATH="$VENV:$PATH"
echo "Fetch roles with ansible-galaxy"
if [ ! -e roles ]; then
  mkdir -p roles
  ansible-galaxy install --roles-path roles "git+https://13pgeiser@github.com/13pgeiser/ansible_machine_demo.git"
fi
echo "Starting QEMU"
qemu_launch tcp::2222-:22 4G debian-preseed-standard.iso
echo "Waiting for SSH connection"
qemu_wait_for_ssh localadmin@localhost 2222
(
  echo "Launch ansible-playbook (ansible_machine_demo)"

	cd roles || exit
	ansible-playbook -i ../inventory "ansible_machine_demo/tasks/main.yml" -vv
)
echo "Calling shutdown!"
ssh -p 2222 localadmin@localhost "sudo poweroff" || true

