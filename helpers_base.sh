#!/bin/bash
warn() { #helpmsg: Print a warning message
	echo >&2 ":: $*"
}

die() { #helpmsg: Print an error message and exit
	echo >&2
	echo >&2 "FATAL!"
	echo >&2 ":: $*"
	exit 1
}

quick_help() { #helpmsg: Print a short help
	grep -E '^.+{ #helpmsg' "$SCRIPT_DIR"/*.sh |
		grep -v '\^.' |
		grep -v 's|()' |
		sed -e 's|() { #helpmsg: |-|g' |
		column -s'-' -t |
		sort
}

check_commands() { #helpmsg: Test if a list of commands is available on the PATH
	local cmd
	for cmd in "$@"; do
		if ! [ -x "$(command -v "$cmd")" ]; then
			die "$cmd is not available!"
		fi
	done
}
