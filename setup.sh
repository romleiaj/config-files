#!/usr/bin/bash
set -e
# Idempotent (ish)

DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd $DIR

echo "Setting up node.js"
sudo bash ${DIR}/nodesource_setup.sh

echo "Installing essential apt packages."
# Install some basic packages guaranteed to be used
sudo apt-get update && sudo apt-get install -y \
aptitude \
htop \
curl \
vim \
git \
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
fish

echo "Installing Nerdfont"
curl -sS https://webi.sh/nerdfont | sh

echo "Installing neovim and astronvim"
arch=$(uname -i)
if [[ $arch == x86_64* ]]; then
    curl -sSLO https://github.com/neovim/neovim/releases/download/v0.11.1/nvim-linux-x86_64.tar.gz
    tar -xzvf nvim-linux-x86_64.tar.gz
    sudo rm -rf /usr/local/share/nvim/runtime /usr/local/bin/nvim
    sudo cp ./nvim-linux-x86_64/bin/nvim /usr/local/bin/nvim
    sudo cp -r ./nvim-linux-x86_64/share/nvim /usr/local/share/
    git clone --depth 1 https://github.com/AstroNvim/template ~/.config/nvim
    rm -rf ~/.config/nvim/.git
    rm -rf ./nvim-linux-x86_64
elif  [[ $arch == arm* ]]; then
    curl -sSLO https://github.com/neovim/neovim/releases/download/v0.11.1/nvim-linux-arm64.tar.gz
    tar -xzvf nvim-linux-arm64.tar.gz
    sudo rm -rf /usr/local/share/nvim/runtime /usr/local/bin/nvim
    sudo cp ./nvim-linux-arm64/bin/nvim /usr/local/bin/nvim
    sudo cp -r ./nvim-linux-arm64/share/nvim /usr/local/share/
    git clone --depth 1 https://github.com/AstroNvim/template ~/.config/nvim
    rm -rf ~/.config/nvim/.git
    rm -rf ./nvim-linux-arm64
fi

#

echo "Installing tmux package manager"
if [ ! -d ~/.tmux/plugins/tpm ]; then
    git clone https://github.com/tmux-plugins/tpm ~/.tmux/plugins/tpm
fi

echo "Installing rust, cargo, tools"
curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh
cargo install ripgrep
cargo install fd-find
cargo install --locked tree-sitter-cli

echo "Installing npm tree-sitter"
npm install tree-sitter

echo "Installing uv"
curl -LsSf https://astral.sh/uv/install.sh | sh
source $HOME/.local/bin/env

echo "Installing python tools with uv (ansible, pynvim, ruff"
uv tool install ruff@latest
uv tool install ansible@latest

echo "Installing fuzzy find"
if [ ! -d /home/xenos/.fzf ]; then
    git clone --depth 1 https://github.com/junegunn/fzf.git ~/.fzf
    ~/.fzf/install
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
if [ ! -f ~/.bash_aliases ]; then
    ln -s ${DIR}/bash_aliases ~/.bash_aliases
fi

cd $DIR

git config --global user.email "adam.romlein@gmail.com"
git config --global user.name  "Adam Romlein"
