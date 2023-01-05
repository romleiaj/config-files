#!/usr/bin/bash

#TODO: Make a swap file
#TODO: Install batcat, wireguard, tmuxinator, poetry, geeqie, fzf, ansible,

DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Install some basic packages guaranteed to be used
sudo apt-get update && sudo apt-get install \
htop \
vim \
nvim \
tmux \
git \
fish

mkdir -p ${DIR}/../.vim/bundle

# Link dotfiles
ln -s ${DIR}/3.3a.tmux.conf ${DIR}/../.tmux.conf
ln -s ${DIR}/.vimrc ${DIR}/../.vimrc
ln -s ${DIR}/.vimrc ${DIR}/../.vim/init.vim

# Install vim theme solarized
source ${DIR}/install_pathogen.sh
source ${DIR}/install_solarized.sh

cd ${DIR}/../.vim/bundle
#git clone https://github.com/yhat/vim-docstring.git

cd $DIR

# setup default git
git config --global user.email "adam.romlein@kitware.com"
git config --global user.name  "Adam Romlein"
