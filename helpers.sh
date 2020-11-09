#!/bin/bash
# (C) P. Geiser
# https://github.com/13pgeiser/bash-helpers
set -eu
LANG=en_US.UTF_8

# Current script folder
SCRIPT_DIR="$(dirname "$(realpath "${BASH_SOURCE[0]}")")"

echo "**********************************************"
echo "* OSTYPE:     $OSTYPE"
echo "* HOSTTYPE:   $HOSTTYPE"
echo "* USER:       $USER"
echo "* SCRIPT_DIR: $SCRIPT_DIR"
echo "**********************************************"
echo

# Source helpers.
# shellcheck source=helpers_base.sh
source "$SCRIPT_DIR/helpers_base.sh"
# shellcheck source=helpers_debian.sh
source "$SCRIPT_DIR/helpers_debian.sh"
# shellcheck source=helpers_docker.sh
source "$SCRIPT_DIR/helpers_docker.sh"
# shellcheck source=helpers_python.sh
source "$SCRIPT_DIR/helpers_python.sh"

# Source local sourceme if it exists.
if [ -e sourceme ]; then
	# shellcheck disable=SC1091
	source sourceme
fi

if [ "${BASH_SOURCE[0]}" == "${0}" ]; then
	echo "This script is designed to be sourced!"
	echo
	_quick_help ""
	_die "Please source me!"
fi
