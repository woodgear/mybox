#!/bin/bash

sudo pacman -S archlinuxcn-keyring
echo "
[archlinuxcn]
Server = https://mirrors.tuna.tsinghua.edu.cn/archlinuxcn/$arch
" >>/etc/pacman.conf

sudo pacman -Syu
sudo pacman -S archlinuxcn-keyring
sudo pacman -S yay --noconfirm
yay --aururl "https://aur.archlinux.org" --save
sudo pacman -S --needed base-devel  --noconfirm

