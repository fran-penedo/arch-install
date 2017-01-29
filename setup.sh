#!/bin/bash -x

# To be run as ./setup.sh 2>&1 | tee log.txt

#### Installation

# wifi-menu

# lsblk

# parted /dev/sdx print
# Look for type: msdos or GPT

# If GPT use cgdisk, if msdos use cfdisk
# use ntfsresize to resize windows partition

# Create filesystems with mkfs.*

# mkswap /dev/sdxY
# swapon /dev/sdxY

# mount /dev/sdxR /mnt
# mount everything else. Mount efi partition to /boot/efi if necessary

# change mirrorlist if needed

# pacstrap -i /mnt base base-devel

# genfstab -U -p /mnt >> /mnt/etc/fstab

# arch-chroot /mnt /bin/bash

# Install dialog and wpa-suplicant for easy wifi configuration in case something goes wrong after reboot

# Set root password with passwd

#### GRUB installation

## BIOS

# Install grub and os-prober

# grub-install --target=i386-pc --recheck /dev/sdx
# grub-mkconfig -o /boot/grub/grub.cfg

## UEFI (not tested yet)

# Install grub efibootmgr and os-prober

# grub-install --target=x86_64-efi --efi-directory=/boot/efi --bootloader-id=grub --recheck
# grub-mkconfig -o /boot/grub/grub.cfg
# TODO fix windows not being added to list

#### Post reboot

nano /etc/locale.gen
locale-gen
echo LANG=en_US.UTF-8 > /etc/locale.conf
export LANG=en_US.UTF-8

ln -sf /usr/share/zoneinfo/US/Eastern /etc/localtime

echo fpc > /etc/hostname
echo Add fpc at the end of all lines
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
