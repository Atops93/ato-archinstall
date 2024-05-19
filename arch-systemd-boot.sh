#!/usr/bin/env bash

echo "Enter Root paritition: (example /dev/sda3)"
read ROOT

echo "Enter SWAP paritition: (example /dev/sda2)"
read SWAP

echo "Enter EFI paritition: (example /dev/sda1 or /dev/nvme0n1p1)"
read EFI

mkfs.ext4 "ROOT" "${ROOT}"
mkswap "${SWAP}"
mkfs.fat -F 32 "${EFI}"

mount "${ROOT}" /mnt
swapon "${SWAP}"
mkdir -p /mnt/boot/efi
mount "${EFI}" /mnt/boot/efi

pacstrap -K /mnt base linux linux-firmware grub efibootmgr networkmanager intel-ucode neovim

genfstab -U /mnt >> /mnt/etc/fstab

arch-chroot /mnt

ln -sf /usr/share/zoneinfo/Australia/Adelaide /etc/localtime
hwclock --systohc

sed -i 's/^#en_US.UTF-8 UTF-8/en_US.UTF-8 UTF-8/' /etc/locale.gen
locale-gen
echo "LANG=en_US.UTF-8" >> /etc/locale.conf

/etc/hostname >> Arch-Btw

echo "Set root password"
read ROOTPASW

passwd "${ROOTPASW}"

echo "Enter your username"
read USER

echo "Enter your password"
read PASSWORD

useradd -m $USER
usermod -aG wheel, $USER
echo $USER:$PASSWORD | chpasswd
sed -i 's/^# %wheel ALL=(ALL:ALL) ALL/%wheel ALL=(ALL:ALL) ALL/' /etc/sudoers

## SYSTEMD BOOTLOADER
bootctl install --path /mnt/boot
echo "default arch.conf" >> /mnt/boot/loader/loader.conf
cat <<EOF > /mnt/boot/loader/entries/arch.conf
title Arch Linux
linux /vmlinuz-linux
initrd /initramfs-linux.img
options root=${ROOT} rw
EOF

systemctl enable NetworkManager

echo "Type. :umount -R /mnt: then type :reboot:"