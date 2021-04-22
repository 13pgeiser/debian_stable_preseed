#!/bin/bash
# (C) P. Geiser
# https://github.com/13pgeiser/bash-helpers
set -eu
LANG=en_US.UTF_8

# Current script folder
SCRIPT_DIR="$(dirname "$(realpath "${BASH_SOURCE[0]}")")"

# Set TOOLS_FOLDER variable.
if [ -z ${TOOLS_FOLDER+x} ]; then
	if [ -d ../../_tools ]; then
		TOOLS_FOLDER=$(realpath ../../_tools)
	elif [ -d ../_tools ]; then
		TOOLS_FOLDER=$(realpath ../_tools)
	else
		TOOLS_FOLDER=$(realpath tools)
	fi
	export TOOLS_FOLDER
fi

# Set USER when running on msys.
if [ "$OSTYPE" == "msys" ]; then
	export USER="$USERNAME"
fi

echo "**********************************************"
echo "* OSTYPE:        $OSTYPE"
echo "* HOSTTYPE:      $HOSTTYPE"
echo "* USER:          $USER"
echo "* SCRIPT_DIR:    $SCRIPT_DIR"
echo "* TOOLS_FOLDER:  $TOOLS_FOLDER"
echo "**********************************************"
echo

# Source helpers.
# shellcheck source=helpers_base.sh
source "$SCRIPT_DIR/helpers_base.sh"
# shellcheck source=helpers_cpp.sh
source "$SCRIPT_DIR/helpers_cpp.sh"
# shellcheck source=helpers_debian.sh
source "$SCRIPT_DIR/helpers_debian.sh"
# shellcheck source=helpers_docker.sh
source "$SCRIPT_DIR/helpers_docker.sh"
# shellcheck source=helpers_python.sh
source "$SCRIPT_DIR/helpers_python.sh"
# shellcheck source=helpers_qemu.sh
source "$SCRIPT_DIR/helpers_qemu.sh"

# Source local sourceme if it exists.
if [ -e sourceme ]; then
	# shellcheck disable=SC1091
	source sourceme
fi

if [ "${BASH_SOURCE[0]}" == "${0}" ]; then
	echo "This script is designed to be sourced!"
	echo
	quick_help ""
	die "Please source me!"
fi
