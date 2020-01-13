#!/bin/bash
set -eu

# Fetch bash helpers and source it.
if [ ! -e .bash_helpers.sh ]; then
  curl -kSL https://raw.githubusercontent.com/13pgeiser/bash/master/bash_helpers.sh -o .bash_helpers.sh
fi
source ./.bash_helpers.sh

echo "Starting QEMU"
launch_qemu tcp::2222-:22 4G buster-standard.iso
echo "Waiting for SSH connection"
wait_for_ssh localadmin@localhost 2222
echo "Copying SSH keys"
copy_ssh_keys localadmin@localhost 2222
echo "Listing slash"
ssh -p 2222 localadmin@localhost "sudo ls /"
echo "Calling shutdown!"
ssh -p 2222 localadmin@localhost "sudo poweroff" || true
