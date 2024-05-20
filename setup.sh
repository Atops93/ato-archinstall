# WELCOME


timedatectl

pacstrap -K /mnt base linux linux-firmware intel-ucode grub networkmanager sof-firmware

genfstab -U /mnt >> /mnt/etc/fstab

arch-chroot /mnt