#!/usr/bin/bash
set -e
# Idempotent (ish)

DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

echo "Adding neovim stable repo."
sudo add-apt-repository ppa:neovim-ppa/stable

echo "Setting up node.js"
sudo bash ${DIR}/nodesource_setup.sh

echo "Installing essential apt packages."
# Install some basic packages guaranteed to be used
sudo apt-get update && sudo apt-get install -y \
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
python3-pip \
python3-setuptools \
python3-pynvim \
nodejs \
ffmpeg \
geeqie \
fd-find \
ripgrep \
fish

# Tmux and tmuxinator
# Add tmux package manager
echo "Installing tmux package manager"
if [ ! -d ~/.tmux/plugins/tpm ]; then
    git clone https://github.com/tmux-plugins/tpm ~/.tmux/plugins/tpm
fi

echo "Installing rust, cargo, tools"
curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh

# Installing tree-sitter with node
echo "Installing npm tree-sitter"
npm install tree-sitter

# uv
echo "Installing uv"
curl -LsSf https://astral.sh/uv/install.sh | sh
source $HOME/.local/bin/env

# ruff install
echo "Installing python tools with uv (ansible, pynvim, ruff"
uv tool install ruff@latest
uv tool install ansible@latest

# Fuzzy Find
echo "Installing fuzzy find"
if [ ! -d /home/xenos/.fzf ]; then
    git clone --depth 1 https://github.com/junegunn/fzf.git ~/.fzf
    ~/.fzf/install
fi

# Nerdfont install
echo "Installing Nerdfont"
curl -sS https://webi.sh/nerdfont | sh

# lunarvim install
echo "Installing LunarVim"
if [ ! -f /home/xenos/.local/bin/lvim ]; then
   LV_BRANCH='release-1.4/neovim-0.9' bash <(curl -s https://raw.githubusercontent.com/LunarVim/LunarVim/release-1.4/neovim-0.9/utils/installer/install.sh)
fi

# Starship install
echo "Installing starship"
if [ ! -f /usr/local/bin/starship ]; then
  curl -sS https://starship.rs/install.sh | sh
  echo "eval "$(starship init bash)"" >> ~/.bashrc
fi

echo "Linking configuration files."
if [ ! -f ~/.tmux.conf ]; then
    ln -s ${DIR}/.tmux.conf ~/.tmux.conf
fi
if [ ! -f ~/.config/fish/config.fish ]; then
    mkdir -p ~/.config/fish
    ln -s ${DIR}/config.fish ~/.config/fish/config.fish
fi
if [ ! -f ~/.config/lvim/config.lua ]; then
    mkdir -p ~/.config/lvim/
    ln -s ${DIR}/lvim_config.lua ~/.config/lvim/config.lua
fi
if [ ! -f ~/.bash_aliases ]; then
    ln -s ${DIR}/bash_aliases ~/.bash_aliases
fi

cd $DIR

# setup default git
git config --global user.email "adam.romlein@gmail.com"
git config --global user.name  "Adam Romlein"
