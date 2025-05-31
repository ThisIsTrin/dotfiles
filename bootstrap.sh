#!/bin/bash
set -e

echo "==> Installing base packages..."
pacman -Syu --noconfirm git base-devel

echo "==> Cloning dotfiles..."
git clone --bare git@github.com:ThisIsTrin/dotfiles.git $HOME/.dotfiles
alias dotfiles='/usr/bin/git --git-dir=$HOME/.dotfiles/ --work-tree=$HOME'
dotfiles checkout
dotfiles config --local status.showUntrackedFiles no

echo "==> Installing packages from pkglist.txt..."
sudo pacman -S --needed - < ~/pkglist.txt

echo "==> Installing AUR helper (yay)..."
git clone https://aur.archlinux.org/yay.git && cd yay && makepkg -si --noconfirm

echo "==> Installing AUR packages..."
yay -S --needed - < ~/aurlist.txt

echo "==> Done!"
