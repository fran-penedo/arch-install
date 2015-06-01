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
# mount everything else

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

#### Post reboot

vi /etc/locale.gen
locale-gen
echo LANG=en_US.UTF-8 > /etc/locale.conf
export LANG=en_US.UTF-8

ln -sf /usr/share/zoneinfo/US/Eastern /etc/localtime

echo fpc > /etc/hostname
vi /etc/hosts

vi /etc/pacman.conf

pacman -Syu
pacman -S --noconfirm zsh

useradd -m -G wheel -s /bin/zsh fran
passwd fran

nano /etc/sudoers

su fran

sudo pacman -S --noconfirm wget

mkdir install
cd install

wget https://aur.archlinux.org/packages/pa/package-query-git/package-query-git.tar.gz
tar -xvf package-query-git.tar.gz
cd package-query-git
makepkg -s --noconfirm
sudo pacman -U --noconfirm *.tar.xz
cd ..

wget https://aur.archlinux.org/packages/ya/yaourt-git/yaourt-git.tar.gz
tar -xvf yaourt-git.tar.gz
cd yaourt-git
makepkg -s --noconfirm
sudo pacman -U --noconfirm *.tar.xz
cd ..

cd ..
rm -rf install

yaourt -S --noconfirm pkglist.txt
yaourt -S --noconfirm pkglistaur.txt
while read i
do
    sudo pip install $i
done < pkglistpip.txt

git clone https://github.com/fran-penedo/dotfiles.git dotfiles
cd dotfiles
sh makesymlinks.sh
cd ..

sudo ln -s /bin/google-chrome-stable /bin/chrome

git clone https://github.com/fran-penedo/oh-my-zsh.git .oh-my-zsh

sudo cp 00-keyboard.conf /etc/X11/xorg.conf.d/

systemctl enable slim.service
systemctl enable NetworkManager.service

