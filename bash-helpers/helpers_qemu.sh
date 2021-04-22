#!/bin/bash

qemu_wait_for_ssh() { #helpmsg: Wait for SSH connection. Usage: wait_for_ssh "user@host" "port"
	install_debian_packages sshpass openssh-client
	local ret=-1
	while [ $ret -ne 0 ]; do
		sshpass -p insecure ssh -o "UserKnownHostsFile=/dev/null" -o "StrictHostKeyChecking=no" -p "$2" "$1" 'cat /etc/hostname' && ret=$? || ret=$?
		if [ $ret -ne 0 ]; then
			sleep 5
		fi
	done
}

qemu_copy_ssh_keys() { #helpmsg: Copy public key for SSH connection. Usage: copy_ssh_keys "user@host" "port"
	install_debian_packages sshpass openssh-client
	if [ ! -e "$HOME/.ssh/id_rsa" ]; then
		mkdir -p "$HOME/.ssh"
		ssh-keygen -t rsa -q -P "" -f "$HOME/.ssh/id_rsa"
	fi
	if [ ! -e "$HOME/.ssh/known_hosts" ]; then
		touch "$HOME/.ssh/known_hosts"
	fi
	echo ssh-keygen -f "$HOME/.ssh/known_hosts" -R "[${1##*@}]:$2"
	ssh-keygen -f "$HOME/.ssh/known_hosts" -R "[${1##*@}]:$2"
	echo sshpass -p insecure ssh-copy-id -o "UserKnownHostsFile=/dev/null" -o "StrictHostKeyChecking=no" -p "$2" "$1"
	sshpass -p insecure ssh-copy-id -o "UserKnownHostsFile=/dev/null" -o "StrictHostKeyChecking=no" -p "$2" "$1"
	echo ssh -p "$2" -o "StrictHostKeyChecking=accept-new" "$1" 'cat /etc/hostname'
	ssh -p "$2" -o "StrictHostKeyChecking=accept-new" "$1" 'cat /etc/hostname'
}

qemu_launch() { #helpmsg: Start QEMU. Usage: lauch_qemu "port" "disk_size" "cdrom"
	install_debian_packages qemu-kvm qemu-utils cpu-checker
	if [ ! -e hda.tmp ]; then
		qemu-img create -f qcow2 hda.tmp "$2"
	fi
	QEMU_CMD="qemu-system-x86_64 \
    -daemonize \
    -pidfile qemu.pid \
    -hda hda.tmp \
    -cdrom $3 \
    -smp cpus=$(getconf _NPROCESSORS_ONLN) \
    -m 1024 \
    -vga qxl \
    -vnc :0 \
    -net nic,model=virtio \
    -net user,hostfwd=$1"
	if sudo kvm-ok; then
		if [ -w /dev/kvm ]; then
			QEMU_CMD="$QEMU_CMD -enable-kvm"
		fi
	fi
	echo "$QEMU_CMD"
	if fuser qemu.pid; then
		echo "Qemu is already running!"
	else
		$QEMU_CMD
	fi
}
