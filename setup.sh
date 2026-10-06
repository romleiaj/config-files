#!/usr/bin/bash
#NOTE: Must be run as sudo
set -e

DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd $DIR

echo "Setting up node.js"
sudo bash ${DIR}/nodesource_setup.sh

echo "Setting up cmake keys"
wget -O - https://apt.kitware.com/keys/kitware-archive-latest.asc 2>/dev/null \
  | gpg --dearmor - | sudo tee /usr/share/keyrings/kitware-archive-keyring.gpg >/dev/null
echo 'deb [signed-by=/usr/share/keyrings/kitware-archive-keyring.gpg] https://apt.kitware.com/ubuntu/ noble main' \
  | sudo tee /etc/apt/sources.list.d/kitware.list >/dev/null

echo "Installing essential apt packages."
# Install some basic packages guaranteed to be used
sudo apt-get update && sudo apt-get install -y \
aptitude \
htop \
cmake \
curl \
git \
tmux \
wireguard \
python3-dev \
python3-pip \
python3-setuptools \
python3-pynvim \
nodejs \
ffmpeg \
libclang-dev \
build-essential \
geeqie

sudo apt remove -y vim neovim
sudo apt autoremove -y && sudo apt clean

echo "Installing Nerdfont"
curl -sS https://webi.sh/nerdfont | sh

echo "Installing neovim and astronvim"
arch=$(uname -i)
if [[ $arch == x86_64* ]]; then
    curl -sSLO https://github.com/neovim/neovim/releases/download/v0.11.1/nvim-linux-x86_64.tar.gz
    tar -xzvf nvim-linux-x86_64.tar.gz
    rm -rf ${HOME}/.config/nvim
    sudo rm -rf /usr/local/share/nvim/runtime /usr/local/bin/nvim
    sudo cp ./nvim-linux-x86_64/bin/nvim /usr/local/bin/nvim
    sudo cp -r ./nvim-linux-x86_64/share/nvim /usr/local/share/
    git clone --depth 1 https://github.com/AstroNvim/template ~/.config/nvim
    cp $DIR/python-dev.lua ~/.config/nvim/lua/plugins/
    rm -rf ~/.config/nvim/.git
elif  [[ $arch == aarch* ]]; then
    curl -sSLO https://github.com/neovim/neovim/releases/download/v0.11.1/nvim-linux-arm64.tar.gz
    tar -xzvf nvim-linux-arm64.tar.gz
    rm -rf ${HOME}/.config/nvim
    sudo rm -rf /usr/local/share/nvim/runtime /usr/local/bin/nvim
    sudo cp ./nvim-linux-arm64/bin/nvim /usr/local/bin/nvim
    sudo cp -r ./nvim-linux-arm64/share/nvim /usr/local/share/
    git clone --depth 1 https://github.com/AstroNvim/template ~/.config/nvim
    cp $DIR/python-dev.lua ~/.config/nvim/lua/plugins/
    rm -rf ~/.config/nvim/.git
fi
rm -rf ./nvim-linux*

echo "Installing tmux package manager"
if [ ! -d ~/.tmux/plugins/tpm ]; then
    git clone https://github.com/tmux-plugins/tpm ~/.tmux/plugins/tpm
fi

echo "Installing rust, cargo, tools"
curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y
. "$HOME/.cargo/env"
rustup toolchain install stable
cargo install ripgrep
cargo install fd-find

echo "Installing npm tree-sitter"
npm install tree-sitter

echo "Installing uv"
curl -LsSf https://astral.sh/uv/install.sh | sh
uv generate-shell-completion bash
echo 'eval "$(uv generate-shell-completion bash)"' >> ~/.bashrc

echo "Installing ruff with uv"
uv tool install ruff@latest --force

echo "Installing fuzzy find"
if [ ! -d ${HOME}/.fzf ]; then
    git clone --depth 1 https://github.com/junegunn/fzf.git ${HOME}/.fzf
    ${HOME}/.fzf/install --all
fi

echo "Checking for and optionally installing docker"
if command -v docker &>/dev/null; then
    echo "Docker found, not installing"
else
    echo "Docker not found, installing"
    bash ${DIR}/get-docker.sh
fi
echo "Creating docker group"
sudo groupadd -f docker
sudo usermod -aG docker $USER

echo "Linking configuration files."
if [ ! -f ~/.tmux.conf ]; then
    ln -sf ${DIR}/.tmux.conf ~/.tmux.conf
fi
if [ ! -f ~/.bash_aliases ]; then
    ln -sf ${DIR}/bash_aliases ~/.bash_aliases
fi

cd $DIR

git config --global user.email "adam.romlein@gmail.com"
git config --global user.name  "Adam Romlein"
