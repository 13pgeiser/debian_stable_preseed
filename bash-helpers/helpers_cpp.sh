#!/bin/bash

download() { #helpmsg: Download url (using curl) and verify the file (_download <md5> <url> [<archive>])
	check_commands curl md5sum
	local archive
	if [ -z "$3" ]; then
		archive="$(basename "$2")"
	else
		archive="$3"
	fi
	if [ ! -e "$TOOLS_FOLDER/$archive" ]; then
		mkdir -p "$TOOLS_FOLDER"
		cmd="curl -kSL $2 --progress-bar -o $TOOLS_FOLDER/${archive}.tmp"
		$cmd
		if [[ "$(md5sum "$TOOLS_FOLDER/${archive}.tmp" | cut -d' ' -f1)" != "$1" ]]; then
			die "Invalid md5sum for $archive: $(md5sum "TOOLS_FOLDER/${archive}.tmp")"
		fi
		mv "$TOOLS_FOLDER/${archive}.tmp" "$TOOLS_FOLDER/$archive"
	fi
}

install_7zip() { #helpmsg: install 7zip
	case "$OSTYPE" in
	msys)
		download_unpack 2fac454a90ae96021f4ffc607d4c00f8 https://www.7-zip.org/a/7za920.zip "cp" "" ""
		local archive
		local folder
		local url
		url="https://www.7-zip.org/a/7z1902-x64.exe"
		archive="$(basename $url)"
		folder="${archive%.*}"
		download 6fe79bec6bf751293a1271bd739c8eb0 $url ""
		if [ ! -d "$TOOLS_FOLDER/$folder" ]; then
			7za x "-o$TOOLS_FOLDER/$folder" "$TOOLS_FOLDER/$archive" 2>/dev/null 1>/dev/null
		fi
		PATH="$TOOLS_FOLDER/$folder:$PATH"
		;;
	linux*)
		install_debian_packages p7zip-full
		;;
	*)
		die "Unsupported OS: $OSTYPE"
		;;
	esac
}

install_zstd() {
	case "$OSTYPE" in
	msys)
		local result
		result=$(download_unpack \
			ad62ccda0e8a0665b730faff92bd4308 \
			https://repo.msys2.org/mingw/x86_64/mingw-w64-x86_64-zstd-1.4.4-1-any.pkg.tar.xz \
			"ce" "" "")
		PATH="$result/mingw64/bin:$PATH"
		;;
	linux*)
		install_debian_packages zstd
		;;
	*)
		die "Unsupported OS: $OSTYPE"
		;;
	esac
}

download_unpack() { #helpmsg: Download and unpack archive (_download_unpack <md5> <url> [<flags> <archive> <folder>])
	# flags: 'c' -> create_folder
	# flags: 'e' -> echo final folder
	# flags: 'p' -> add folder to PATH
	# flags: 'd' -> echo destination folder
	local archive
	local folder
	local extension
	local base_name
	local extension_bis
	local dst_folder
	local result
	if [ -z "$4" ]; then
		archive="$(basename "$2")"
	else
		archive="$4"
	fi
	download "$1" "$2" "$archive"
	extension="${archive##*.}"
	base_name="${archive%.*}"
	extension_bis="${base_name##*.}"
	if [ -z "$5" ]; then
		folder="${archive%.*}"
		if [ "$extension_bis" == "tar" ]; then
			folder="${folder%.*}"
		fi
	else
		folder="$5"
	fi
	if [ "$extension_bis" == "tar" ]; then
		extension="$extension_bis.$extension"
	fi
	if echo "$3" | grep -q 'c'; then
		dst_folder="$TOOLS_FOLDER/$folder"
	else
		dst_folder="$TOOLS_FOLDER"
	fi
	if [ ! -e "$dst_folder/.$archive" ]; then
		case "$extension" in
		"zip")
			unzip -q "$TOOLS_FOLDER/$archive" -d "$dst_folder" 2>/dev/null 1>/dev/null
			;;
		"7z" | "rar")
			install_7zip
			7z x -o"$dst_folder" "$TOOLS_FOLDER/$archive" 2>/dev/null 1>/dev/null
			;;
		"tgz" | "tar.gz")
			mkdir -p "$dst_folder"
			tar -C "$dst_folder" -xzf "$TOOLS_FOLDER/$archive" 2>/dev/null 1>/dev/null
			;;
		"tar.xz")
			mkdir -p "$dst_folder"
			tar -C "$dst_folder" -xJf "$TOOLS_FOLDER/$archive" 2>/dev/null 1>/dev/null
			;;
		"tar.bz2")
			mkdir -p "$dst_folder"
			tar -C "$dst_folder" -xjf "$TOOLS_FOLDER/$archive" 2>/dev/null 1>/dev/null
			;;
		"tar.zst")
			install_zstd
			mkdir -p "$dst_folder"
			tar -C "$dst_folder" -I zstd -xf "$TOOLS_FOLDER/$archive" 2>/dev/null 1>/dev/null
			;;
		*)
			die "Unsupported file extension: $extension"
			;;
		esac
		touch "$dst_folder/.$archive"
	fi
	if echo "$3" | grep -q 'p'; then
		PATH="$dst_folder:$PATH"
	fi
	result="$TOOLS_FOLDER/$folder"
	if echo "$3" | grep -q 'e'; then
		echo "$result"
	fi
}

install_subversion() { #helpmsg: Install subversion command line tool
	case "$OSTYPE" in
	msys)
		local result
		result=$(download_unpack \
			757a8abc7bcf363f57c7aea34bcd3a36 \
			https://www.visualsvn.com/files/Apache-Subversion-1.13.0.zip \
			"ce" "" "")
		PATH="$result/bin:$PATH"
		;;
	linux*)
		install_debian_packages subversion
		;;
	*)
		die "Unsupported OS: $OSTYPE"
		;;
	esac
}

install_buildessentials() { #helpmsg: Install essential build files
	case "$OSTYPE" in
	msys)
		local result
		result=$(download_unpack \
			55c00ca779471df6faf1c9320e49b5a9 \
			https://downloads.sourceforge.net/project/mingw-w64/Toolchains%20targetting%20Win64/Personal%20Builds/mingw-builds/8.1.0/threads-posix/seh/x86_64-8.1.0-release-posix-seh-rt_v6-rev0.7z \
			"ce" "" "")
		PATH="$result/mingw64/bin:$PATH"
		result=$(download_unpack \
			ebd514e7030f5adcaea37aa327954320 \
			https://repo.msys2.org/msys/x86_64/make-4.3-1-x86_64.pkg.tar.xz \
			"cep" "" "")
		PATH="$result/usr/bin:$PATH"
		;;
	linux*)
		install_debian_packages build-essential
		;;
	*)
		die "Unsupported OS: $OSTYPE"
		;;
	esac
}

install_ninja() { #helpmsg: Install ninja build
	case "$OSTYPE" in
	msys)
		download_unpack \
			14764496d99bb5ea99e761dab9a38bc4 \
			https://github.com/ninja-build/ninja/releases/download/v1.9.0/ninja-win.zip \
			"cp" "" ""
		;;
	linux*)
		install_debian_packages ninja
		;;
	*)
		die "Unsupported OS: $OSTYPE"
		;;
	esac
}

install_cmake() { #helpmsg: Install cmake
	case "$OSTYPE" in
	msys)
		install_ninja
		local result
		result=$(download_unpack \
			f97acefa282588f05c6528d6db37c570 \
			https://github.com/Kitware/CMake/releases/download/v3.15.5/cmake-3.15.5-win64-x64.zip \
			"e" "" "")
		PATH="$result/bin:$PATH"
		;;
	linux*)
		install_debian_packages cmake
		;;
	*)
		die "Unsupported OS: $OSTYPE"
		;;
	esac
}

install_gcc_arm_none_eabi() { #helpmsg: Install gcc for arm target.
	case "$OSTYPE" in
	msys)
		local result
		result=$(download_unpack \
			82525522fefbde0b7811263ee8172b10 \
			https://developer.arm.com/-/media/Files/downloads/gnu-rm/9-2019q4/RC2.1/gcc-arm-none-eabi-9-2019-q4-major-win32.zip.bz2 \
			"ce" "gcc-arm-none-eabi-9-2019-q4-major-win32.zip" "")
		PATH="$result/bin:$PATH"
		;;
	linux*)
		local result
		result=$(download_unpack \
			fe0029de4f4ec43cf7008944e34ff8cc \
			https://developer.arm.com/-/media/Files/downloads/gnu-rm/9-2019q4/RC2.1/gcc-arm-none-eabi-9-2019-q4-major-x86_64-linux.tar.bz2 \
			"ce" "" "")
		PATH="$result/gcc-arm-none-eabi-9-2019-q4-major/bin:$PATH"
		;;
	*)
		die "Unsupported OS: $OSTYPE"
		;;
	esac
	if [ -x "$(command -v "cmake")" ]; then
		cat <<EOF >arm-none-eabi.cmake
# Automatically created by the configure script
# DO NOT EDIT MANUALLY!
set(CMAKE_SYSTEM_NAME Generic)
set(CMAKE_SYSTEM_PROCESSOR arm)
set(CMAKE_C_COMPILER arm-none-eabi-gcc)
set(CMAKE_CXX_COMPILER arm-none-eabi-g++)
set(CMAKE_ASM_COMPILER arm-none-eabi-gcc)
set(CMAKE_OBJCOPY arm-none-eabi-objcopy)
set(CMAKE_OBJDUMP arm-none-eabi-objdump)
set(CMAKE_TRY_COMPILE_TARGET_TYPE STATIC_LIBRARY)
set(CMAKE_FIND_ROOT_PATH_MODE_PROGRAM NEVER)
set(CMAKE_FIND_ROOT_PATH_MODE_LIBRARY ONLY)
set(CMAKE_FIND_ROOT_PATH_MODE_INCLUDE ONLY)
set(CMAKE_FIND_ROOT_PATH_MODE_PACKAGE ONLY)
EOF
	fi
}

write_sourceme() { #helpmsg: Write a "sourceme" file with some alias and the actual PATH.
	cat <<EOF >sourceme
#!/bin/bash
export LANG=C
alias tags="ctags -R --c++-kinds=+p --fields=+iaS --extra=+q ."
alias ls='ls -F --color --show-control-chars'
export LC_MESSAGES=C

g() {
  gitk --all &
}

gg() {
  gitk --all &
  git gui &
}
EOF
	echo "PATH=\"$PATH\"" >>"$PWD/sourceme"
	# shellcheck disable=SC1090
	source "$PWD/sourceme"
}

call_cmake() { #helpmsg: Correctly call cmake both on Linux and Msys2
	install_cmake
	rm -rf CMakeFiles/
	rm -f CMakeCache.txt cmake_install.cmake compile_commands.json Makefile
	case "$OSTYPE" in
	msys)
		cmake -G "MSYS Makefiles" . "$@"
		;;
	linux*)
		cmake . "$@"
		;;
	*)
		die "Unsupported OS: $OSTYPE"
		;;
	esac
}
