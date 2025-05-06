#!/usr/bin/bash
set -e

DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

sudo add-apt-repository ppa:neovim-ppa/stable

# Install some basic packages guaranteed to be used
sudo apt-get update && sudo apt-get install \
aptitude \
htop \
vim \
git \
neovim \
kazam \
bat \
caffeine \
wireguard \
python3-dev \
python3-setuptools \
ffmpeg \
geeqie \
fd-find \
ripgrep \
fish

# Tmux and tmuxinator
# Add tmux package manager
git clone https://github.com/tmux-plugins/tpm ~/.tmux/plugins/tpm

# Pip and ansible
curl -sSL https://bootstrap.pypa.io/get-pip.py -o get-pip.py && python3 get-pip.py --user
python3 -m pip install --user ansible

# uv
curl -LsSf https://astral.sh/uv/install.sh | sh

# ruff install
uv tool install ruff@latest

# Fuzzy Find
rm -rf ~/.fzf
git clone --depth 1 https://github.com/junegunn/fzf.git ~/.fzf
~/.fzf/install

# Nerdfont install
curl -sS https://webi.sh/nerdfont | sh

# Starship install
curl -sS https://starship.rs/install.sh | sh
echo "eval "$(starship init bash)"" >> ~/.bashrc

mkdir -p ${DIR}/../.config/fish/

# Link dotfiles
ln -s ${DIR}/.tmux.conf ${DIR}/../.tmux.conf
mkdir -p ~/.config/fish
ln -s ${DIR}/config.fish ${DIR}/.config/fish/config.fish
mkdir -p ~/.config/lvim/
ln -s ${DIR}/lvim_config.lua ~/.config/lvim/config.lua

cd $DIR

# setup default git
git config --global user.email "adam.romlein@gmail.com"
git config --global user.name  "Adam Romlein"
