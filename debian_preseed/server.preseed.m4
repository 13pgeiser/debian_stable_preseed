# vim:set ft=dockerfile:
include(`preseed.m4')
include(partman.m4)


d-i partman-auto/expert_recipe string         \
   gpt-boot-root ::                           \
      1 1 1 free                              \
         $bios_boot{ }                        \
         method{ biosgrub } .                 \
      200 200 200 fat32                       \
         $primary{ }                          \
         method{ efi } format{ } .            \
      512 512 512 ext3                        \
         $primary{ } $bootable{ }             \
         method{ format } format{ }           \
         use_filesystem{ } filesystem{ ext3 } \
         mountpoint{ /boot } .                \
      20000 1024 40000 ext4                   \
         $primary{ }                          \
         method{ format } format{ }           \
         use_filesystem{ } filesystem{ ext4 } \
         mountpoint{ / } .                    \
      1000 1024 -1 ext4                      \
         $primary{ }                          \
         method{ format } format{ }           \
         use_filesystem{ } filesystem{ ext4 } \
         mountpoint{ /var } .

