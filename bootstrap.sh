#!/bin/bash
set -e

echo "==> Installing base packages..."
sudo pacman -Syu --noconfirm git base-devel

echo "==> Installing Firefox..."
sudo pacman -S --noconfirm firefox

echo "==> Checking for existing SSH key..."
KEY="$HOME/.ssh/id_ed25519.pub"

if [[ -f "$KEY" ]]; then
    echo "SSH key already exists."
else
    echo "No SSH key found. Generating new SSH key..."
    read -rp "Enter your GitHub email: " email
    ssh-keygen -t ed25519 -C "$email"
    eval "$(ssh-agent -s)"
    ssh-add ~/.ssh/id_ed25519
fi

echo "==> Your public SSH key:"
cat "$KEY"

if command -v wl-copy &>/dev/null; then
    cat "$KEY" | wl-copy
    echo "Public key copied to clipboard using wl-copy"
elif command -v xclip &>/dev/null; then
    cat "$KEY" | xclip -selection clipboard
    echo "Public key copied to clipboard using xclip"
elif command -v xsel &>/dev/null; then
    cat "$KEY" | xsel --clipboard
    echo "Public key copied to clipboard using xsel"
else
    echo "Could not find clipboard tool (wl-copy/xclip/xsel). Please install one."
fi

echo "==> Opening GitHub to add the key..."
firefox "https://github.com/settings/ssh/new"

read -rp "Press ENTER after adding your SSH key to GitHub..."

echo "==> Cloning dotfiles..."
if ssh -T git@github.com 2>&1 | grep -q "successfully authenticated"; then
    git clone --bare git@github.com:ThisIsTrin/dotfiles.git $HOME/.dotfiles
else
    echo "SSH not set up, falling back to HTTPS..."
    git clone --bare https://github.com/ThisIsTrin/dotfiles.git $HOME/.dotfiles
fi

if [ ! -d "$HOME/.dotfiles" ]; then
    echo "Dotfiles clone failed."
    exit 1
fi

function dotfiles {
   /usr/bin/git --git-dir=$HOME/.dotfiles/ --work-tree=$HOME "$@"
}

echo "==> Checking out dotfiles..."
mkdir -p .dotfiles-backup
dotfiles checkout 2>&1 | grep -E "^\s+" | awk '{print $1}' | while read -r file; do
    mkdir -p "$(dirname "$HOME/.dotfiles-backup/$file")"
    mv "$HOME/$file" "$HOME/.dotfiles-backup/$file"
done

dotfiles checkout

dotfiles config --local status.showUntrackedFiles no

echo "==> Installing packages from pkglist.txt..."
if [[ -f ~/pkglist.txt ]]; then
    sudo pacman -S --needed --noconfirm $(< ~/pkglist.txt)
else
    echo "Missing pkglist.txt"
    exit 1
fi

echo "==> Installing AUR helper (yay)..."
if ! command -v yay &> /dev/null; then
    git clone https://aur.archlinux.org/yay.git /tmp/yay
    pushd /tmp/yay
    makepkg -si --noconfirm
    popd
    rm -rf /tmp/yay
fi

echo "==> Installing AUR packages..."
if [[ -f ~/aurlist.txt ]]; then
    yay -S --needed --noconfirm $(< ~/aurlist.txt)
else
    echo "Missing aurlist.txt"
    exit 1
fi

echo "==> Setting up symlink for custom apps..."
mkdir -p ~/.local/share/applications/custom_apps
ln -sf ~/.config/custom_apps/connect-vpn.desktop ~/.local/share/applications/custom_apps/connect-vpn.desktop
ln -sf ~/.config/custom_apps/spotify-player.desktop ~/.local/share/applications/custom_apps/spotify-player.desktop

echo "==> Done!"
