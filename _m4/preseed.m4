#### Preconfiguration file for buster

### Locale + Keyboard
d-i debian-installer/language string en
d-i debian-installer/country string CH
d-i debian-installer/locale string en_US.UTF-8
keyboard-configuration keyboard-configuration/layout select Swiss
keyboard-configuration keyboard-configuration/variantcode string French

### Network
d-i netcfg/choose_interface select auto

### Host name
d-i netcfg/get_hostname string preseeddebian
d-i netcfg/get_domain string pgeiser.com

### If firmware needed
d-i hw-detect/load_firmware boolean true

### Mirror settings
d-i mirror/country string manual
d-i mirror/http/hostname string ftp.ch.debian.org
d-i mirror/http/directory string /debian
d-i mirror/http/proxy string

### Account setup
d-i passwd/root-login boolean false
d-i passwd/user-fullname string Deployment User
d-i passwd/username string localadmin
changequote({{,}})dnl
ifdef({{HASH_PASSWD}},
# printf "<password>" | mkpasswd -s -m sha-512 # to regenerate (package whois)
d-i passwd/user-password-crypted password {{HASH_PASSWD}}
,
d-i passwd/user-password password insecure
d-i passwd/user-password-again password insecure
)
changequote()dnl

### Clock and time zone setup
d-i clock-setup/utc boolean true
d-i time/zone string Europe/Zurich
d-i clock-setup/ntp boolean false
d-i clock-setup/ntp-server string pool.ntp.org

### Partman GPT root + home + noswap
d-i partman/alignment string cylinder
d-i partman-basicfilesystems/choose_label string gpt
d-i partman-basicfilesystems/default_label string gpt
d-i partman-partitioning/choose_label string gpt
d-i partman-partitioning/default_label string gpt
d-i partman/choose_label string gpt
d-i partman/default_label string gpt
partman-partitioning partman-partitioning/choose_label select gpt
d-i partman-auto/method string regular
d-i partman-lvm/device_remove_lvm boolean true
d-i partman-md/device_remove_md boolean true
d-i partman-lvm/confirm boolean true
d-i partman-lvm/confirm_nooverwrite boolean true
d-i partman-auto/choose_recipe select gpt-boot-root
d-i partman-md/confirm boolean true
d-i partman-partitioning/confirm_write_new_label boolean true
d-i partman/choose_partition select finish
d-i partman/confirm boolean true
d-i partman/confirm_nooverwrite boolean true
d-i partman-basicfilesystems/no_swap boolean false
d-i partman/mount_style select uuid
d-i partman-efi/non_efi_system boolean true

### Apt setup
d-i apt-setup/use_mirror boolean true
d-i apt-setup/non-free boolean true
d-i apt-setup/contrib boolean true
d-i apt-setup/services-select multiselect security, updates
d-i apt-setup/security_host string security.debian.org

### Package selection
tasksel tasksel/first multiselect server
d-i pkgsel/include string sudo console-setup openssh-server sshpass less net-tools python3

d-i pkgsel/upgrade select full-upgrade
popularity-contest popularity-contest/participate boolean false

### Boot loader installation
d-i grub-installer/only_debian boolean true
d-i grub-installer/with_other_os boolean true
d-i grub-installer/bootdev  string default
d-i finish-install/reboot_in_progress note

### Early commands
d-i partman/early_command \
       string debconf-set partman-auto/disk "$(list-devices disk | head -n1)"

### Late commands
d-i preseed/late_command string \
echo "#### /tmp mounted with tmpfs"; \
    in-target cp /usr/share/systemd/tmp.mount /etc/systemd/system/tmp.mount; \
    in-target systemctl enable tmp.mount; \
echo "#### NOPASSWD for sudo group in Sudoers" ; \
    in-target sed -i 's/%sudo\tALL=(ALL:ALL) ALL/%sudo\tALL=(ALL:ALL) NOPASSWD:ALL/g' /etc/sudoers ; \
echo "#### Force keyboard layout to ch"; \
    in-target sed -i 's/XKBLAYOUT.*/XKBLAYOUT="ch"/g' /etc/default/keyboard ; \
    in-target /usr/sbin/dpkg-reconfigure -fnoninteractive keyboard-configuration ; \
    in-target sed -i 's/XKBVARIANT.*/XKBVARIANT="fr"/g' /etc/default/keyboard ; \
    in-target sed -i 's/XKBOPTIONS.*/XKBOPTIONS="terminate:ctrl_alt_bksp"/g' /etc/default/keyboard ; \
changequote(${,}$)dnl
echo "#### Update hostname with MAC address"; \
    NIC=`route | grep '^default' | grep -o '[^ ]*$'` ; \
    MAC=`cat /sys/class/net/$NIC/address | tr -d :` ; \
    sed -i "s/preseeddebian/debian$MAC/g" /target/etc/hostname ; \
    sed -i "s/preseeddebian/debian$MAC/g" /target/etc/hosts ; \
changequote()dnl
echo "Finished!"

