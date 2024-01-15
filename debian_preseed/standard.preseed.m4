# vim:set ft=dockerfile:
include(`preseed.m4')
include(partman.m4)

d-i partman-auto/expert_recipe string         \
   gpt-boot-root ::                           \
	 1 1 1 free            \
	    $bios_boot{ }       \
	    method{ biosgrub } . \
	256 40 256 fat32        \
	    $primary{ }         \
	    $lvmignore{ }       \
	    method{ efi }       \
	    format{ } .          \
	128 512 256 ext2 \
         $primary{ } $bootable{ }             \
	$defaultignore{ } \
	method{ format } format{ } \
	use_filesystem{ } filesystem{ ext3 } \
	mountpoint{ /boot }  .\
	1024 20000 -1 ext4 \
	method{ format } format{ } \
	use_filesystem{ } filesystem{ ext4 } \
	mountpoint{ / } .

