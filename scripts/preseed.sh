#!/bin/bash

# Check preseed.cfg
debconf-set-selections -c preseed.cfg

# Extract iso & make all files writable
xorriso -osirrox on -indev input.iso -extract / isofiles
chmod +w -R isofiles/

# Copy auto.cfg if it exists
if [[ -e auto.cfg ]]; then
    cp auto.cfg /isofiles/isolinux/
fi

# Copy grub.cfg if it exists
if [[ -e grub.cfg ]]; then
    cp grub.cfg /isofiles/boot/grub/
fi

# Patch isolinux
cd isofiles/
sed -i 's/timeout 0/timeout 20/' ./isolinux/isolinux.cfg
sed -i '/menu\ default/d' ./isolinux/gtk.cfg
sed -i '/include stdmenu.cfg/a include auto.cfg' ./isolinux/menu.cfg
cd ..

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

