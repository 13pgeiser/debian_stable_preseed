#!/bin/bash

# Check preseed.cfg
debconf-set-selections -c preseed.cfg

# Extract iso & make all files writable
xorriso -osirrox on -indev input.iso -extract / isofiles
chmod +w -R isofiles/

cp auto.cfg /isofiles/isolinux/
sed -i 's/include gtk.cfg/include auto.cfg/g' isofiles/isolinux/menu.cfg
sed -i 's/include spkgtk.cfg//g' isofiles/isolinux/menu.cfg
sed -i 's/include spk.cfg//g' isofiles/isolinux/menu.cfg
sed -i '/set theme=\/boot\/grub\/theme\/1/r grubauto.cfg' /isofiles/boot/grub/grub.cfg
sed -i '/set theme=\/boot\/grub\/theme\/1/r grubauto.cfg' /isofiles/boot/grub/i386-efi/grub.cfg
sed -i '/set theme=\/boot\/grub\/theme\/1/r grubauto.cfg' /isofiles/boot/grub/x86_64-efi/grub.cfg

# Extract initrd
gunzip isofiles/install.amd/initrd.gz
echo preseed.cfg | cpio -H newc -o -A -F isofiles/install.amd/initrd
gzip isofiles/install.amd/initrd
cd isofiles
find -follow -type f -print0 | xargs --null md5sum > md5sum.txt
cd ..

xorriso -as mkisofs -o output.iso \
	-r \
	-J -J -joliet-long \
	-isohybrid-mbr /usr/lib/ISOLINUX/isohdpfx.bin \
	-b isolinux/isolinux.bin  \
	-c isolinux/boot.cat \
	-boot-load-size 4 -boot-info-table -no-emul-boot \
	-eltorito-alt-boot \
	-e boot/grub/efi.img \
	-no-emul-boot -isohybrid-gpt-basdat isofiles

