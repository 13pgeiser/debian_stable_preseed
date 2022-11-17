#!/bin/bash
set -eu

source ./bash-scripts/helpers.sh

echo "Starting QEMU"
qemu_launch tcp::2222-:22 4G debian-preseed-standard.iso
echo "Waiting for SSH connection"
qemu_wait_for_ssh localadmin@localhost 2222
echo "Copying SSH keys"
qemu_copy_ssh_keys localadmin@localhost 2222
echo "Listing slash"
ssh -p 2222 localadmin@localhost "sudo ls /"
echo "Calling shutdown!"
ssh -p 2222 localadmin@localhost "sudo poweroff" || true
