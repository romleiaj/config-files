#!/usr/bin/bash

DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Install some basic packages guaranteed to be used
sudo apt-get install \
htop \
vim \
tmux

# Link dotfiles
ln -s ${DIR}/.tmux.conf ~/.tmux.conf
ln -s ${DIR}/.vimrc ~/.vimrc

# Install vim theme solarized
source ${DIR}/install_pathogen.sh
source ${DIR}/install_solarized.sh

# setup default git
git config --global user.email "romleiaj@clarkson.edu"
git config --global user.name  "Adam Romlein"
