#!/bin/bash
_warn() { #helpmsg: Print a warning message
	echo >&2 ":: $*"
}

_die() { #helpmsg: Print an error message and exit
	echo >&2
	echo >&2 "FATAL!"
	echo >&2 ":: $*"
	exit 1
}

_quick_help() { #helpmsg: Print a short help
	grep -E '^_.+{ #helpmsg' "$SCRIPT_DIR"/*.sh |
		sed -e 's|() { #helpmsg: |-|g' |
		column -s'-' -t |
		sort
}

_check_commands() { #helpmsg: Test if a list of commands is available on the PATH
	local cmd
	for cmd in "$@"; do
		if ! [ -x "$(command -v "$cmd")" ]; then
			_die "$cmd is not available!"
		fi
	done
}
