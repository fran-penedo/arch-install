#!/bin/bash -x

# To be run as ./setup.sh 2>&1 | tee log.txt

#### Installation

# # wifi-menu # no longer included
# iwctl --passphrase passphrase station device connect SSID

# timedatectl set-ntp true

# lsblk

# parted /dev/sdx print
# Look for type: msdos or GPT

# use ntfsresize to resize windows partition
# ntfsresize -i
# ntfsresize -s 80G -n /dev/nvme0n1
# If GPT use cgdisk, if msdos use cfdisk

# If setting up full disk encryption:
# cryptsetup -y -v --pbkdf pbkdf2 --hash sha256 --iter-time 100 luksFormat /dev/sda2
# cryptsetup open /dev/sda2 root
# mkfs.ext4 /dev/mapper/root
# mount /dev/mapper/root /mnt

# Create filesystems with mkfs.*

# mount /dev/sdxR /mnt
# mount everything else. Mount efi partition to /boot/efi if necessary

# dd if=/dev/zero of=/mnt/swapfile bs=1M count=20480 status=progress
# chmod 600 /mnt/swapfile
# mkswap /mnt/swapfile # /dev/sdxY
# swapon /mnt/swapfile # /dev/sdxY

# reflector --save /etc/pacman.d/mirrorlist --country Spain --protocol https --latest 5 --sort rate

# pacstrap -i /mnt base base-devel linux linux-firmware zsh fish vi vim man-db man-pages texinfo networkmanager

# genfstab -U -p /mnt >> /mnt/etc/fstab

# arch-chroot /mnt /bin/bash

# if encrypted

# dd bs=512 count=4 if=/dev/random of=/crypto_keyfile.bin iflag=fullblock
# chmod 600 /crypto_keyfile.bin
# chmod 600 /boot/initramfs-linux*
# cryptsetup luksAddKey /dev/sdX# /crypto_keyfile.bin

# modify /etc/mkinitcpio.conf
# HOOKS=(base udev autodetect keyboard keymap consolefont modconf block encrypt filesystems fsck)
# FILES=(/crypto_keyfile.bin)
# mkinitcpio -P

# Set root password with passwd

# systemctl enable NetworkManager

#### GRUB installation

## BIOS

# Install grub and os-prober

# grub-install --target=i386-pc --recheck /dev/sdx
# grub-mkconfig -o /boot/grub/grub.cfg

## UEFI (not tested yet)

# Install grub efibootmgr os-prober intel-ucode

# edit /etc/default/grub and uncomment
# GRUB_DISABLE_OS_PROBER=false

# if encrypted
# GRUB_ENABLE_CRYPTODISK=y

# add kernel parameters:
# remove quiet and splash

# if encrypted
# cryptdevice=UUID=[device-UUID]:root
# root=/dev/mapper/root
# resume=/dev/mapper/root
# resume_offset=[offset] (get it from filefrag -v /swapfile | awk '$1=="0:" {print substr($4, 1, length($4)-2)}')

# grub-install --target=x86_64-efi --efi-directory=/boot/efi --bootloader-id=grub --recheck

# if encrypted
# create /root/grub-pre.cfg with:

#set crypto_uuid=[uuid without hyphens]
#cryptomount -u $crypto_uuid
## Replace crypto0 by lvm/NameOfVolume if you use LVM
#set root=crypto0
#set prefix=($root)/boot/grub
#insmod normal
#normal

# grub-mkimage -p /boot/grub -O x86_64-efi -c /root/grub-pre.cfg -o /tmp/grubx64.efi luks2 part_gpt cryptodisk gcry_rijndael pbkdf2 gcry_sha256 ext2
# install -v /tmp/grubx64.efi esp/EFI/GRUB/grubx64.efi

# grub-mkconfig -o /boot/grub/grub.cfg

#### Post reboot

nano /etc/locale.gen
locale-gen
echo LANG=en_US.UTF-8 > /etc/locale.conf
export LANG=en_US.UTF-8

ln -sf /usr/share/zoneinfo/US/Eastern /etc/localtime
hwclock --systohc

echo fpc > /etc/hostname
echo Add fpc at the end of all lines
# 127.0.0.1	localhost.localdomain	localhost fpc
# ::1		localhost.localdomain	localhost fpc
read
nano /etc/hosts

echo Enable multilib
read
nano /etc/pacman.conf

pacman -Syu
pacman -S --noconfirm zsh

useradd -m -G wheel -s /bin/zsh fran
passwd fran

# TODO This wont work with tee
echo Enable wheel group
read
visudo
