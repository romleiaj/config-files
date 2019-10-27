#!/usr/bin/bash

DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

sudo apt-get install \
htop \
vim \
tmux

ln -s ${DIR}/.tmux.conf ~/.tmux.conf
ln -s ${DIR}/.vimrc ~/.vimrc

source ${DIR}/install_pathogen.sh
source ${DIR}/install_solarized.sh
