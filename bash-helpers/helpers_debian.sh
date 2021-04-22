#!/bin/bash
install_debian_packages() { #helpmsg: Install a list of debian packages using sudo
	check_commands dpkg-query apt-get sudo
	local package
	for package in "$@"; do
		if ! dpkg-query -f '${Status}' -s "$package" | grep 'install ok' 2>/dev/null 1>/dev/null; then
			echo "Installing $package"
			sudo apt-get -y install "$package"
		fi
	done
}
