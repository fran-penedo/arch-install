#!/bin/bash -x
cd

SCRIPTDIR=/home/fran/arch-install

sudo pacman -S --noconfirm --needed wget

mkdir install
cd install

wget https://aur.archlinux.org/cgit/aur.git/snapshot/package-query-git.tar.gz
tar -xvf package-query-git.tar.gz
cd package-query-git
makepkg -s --noconfirm
sudo pacman -U --noconfirm *.tar.xz
cd ..

wget https://aur.archlinux.org/cgit/aur.git/snapshot/yaourt-git.tar.gz
tar -xvf yaourt-git.tar.gz
cd yaourt-git
makepkg -s --noconfirm
sudo pacman -U --noconfirm *.tar.xz
cd ..

cd ..
rm -rf install

yaourt -S --noconfirm --needed $SCRIPTDIR/pkglist.txt
yaourt -S --noconfirm --needed $SCRIPTDIR/pkglistaur.txt
while read i
do
    sudo pip install $i
done < $SCRIPTDIR/pkglistpip.txt

git clone https://github.com/fran-penedo/dotfiles.git dotfiles
cd dotfiles
echo "[include]
	path = ../.gitconfig" >> .git/config
sh makesymlinks.sh
cd ..

sudo ln -s /bin/google-chrome-stable /bin/chrome

git clone https://github.com/fran-penedo/oh-my-zsh.git .oh-my-zsh

sudo cp $SCRIPTDIR/00-keyboard.conf /etc/X11/xorg.conf.d/

systemctl enable slim.service
systemctl enable NetworkManager.service

sudo cp resume@.service /etc/systemd/system/
systemctl enable resume@fran.service

sh $SCRIPTDIR/default.sh

cd /usr/share/git/credential/gnome-keyring
sudo make
cd


