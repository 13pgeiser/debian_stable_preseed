#!/bin/bash

#!/bin/bash
set -e

ORIG_ISO="input.iso"
OUT_ISO="output.iso"

# 1. Double check the preseed formatting syntax
debconf-set-selections -c preseed.cfg

# 2. Extract ONLY the tiny boot configuration files we need to change
echo "==> Extracting only targeted boot and configuration files..."
rm -rf boot_patch && mkdir -p boot_patch/isolinux boot_patch/boot/grub boot_patch/install.amd

xorriso -osirrox on -indev "$ORIG_ISO" \
    -extract /isolinux/menu.cfg boot_patch/isolinux/menu.cfg \
    -extract /boot/grub/grub.cfg boot_patch/boot/grub/grub.cfg \
    -extract /boot/grub/x86_64-efi/grub.cfg boot_patch/boot/grub/x86_64-efi/grub.cfg \
    -extract /install.amd/initrd.gz boot_patch/install.amd/initrd.gz

# 3. Patch the text and menu configurations locally
echo "==> Patching boot configurations..."
cp auto.cfg boot_patch/isolinux/
sed -i 's/include gtk.cfg/include auto.cfg/g' boot_patch/isolinux/menu.cfg
sed -i 's/include spkgtk.cfg//g' boot_patch/isolinux/menu.cfg
sed -i 's/include spk.cfg//g' boot_patch/isolinux/menu.cfg
sed -i '/set theme=\/boot\/grub\/theme\/1/r grubauto.cfg' boot_patch/boot/grub/grub.cfg
sed -i '/set theme=\/boot\/grub\/theme\/1/r grubauto.cfg' boot_patch/boot/grub/x86_64-efi/grub.cfg

# 4. Patch the initrd safely in a clean tmp space
echo "==> Modifying initrd..."
mkdir -p /tmp/initrd_mod
cd /tmp/initrd_mod
gunzip -c ../../boot_patch/install.amd/initrd.gz | cpio -idmv --no-absolute-filenames
cp ../../preseed.cfg .
find . | cpio -H newc -o | gzip -9 > ../../boot_patch/install.amd/initrd.gz
cd ../..
rm -rf /tmp/initrd_mod

# 5. Overwrite the files directly inside the ISO map using xorriso injection
echo "==> Mastering new optimized ISO..."
xorriso -indev "$ORIG_ISO" -outdev "$OUT_ISO" \
    -boot_image any replay \
    -map boot_patch/isolinux/auto.cfg /isolinux/auto.cfg \
    -map boot_patch/isolinux/menu.cfg /isolinux/menu.cfg \
    -map boot_patch/boot/grub/grub.cfg /boot/grub/grub.cfg \
    -map boot_patch/boot/grub/x86_64-efi/grub.cfg /boot/grub/x86_64-efi/grub.cfg \
    -map boot_patch/install.amd/initrd.gz /install.amd/initrd.gz \
    -padding 0

# Clean up local working directories
rm -rf boot_patch
echo "==> Done! Output saved to $OUT_ISO"
