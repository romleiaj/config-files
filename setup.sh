#!/usr/bin/bash
set -e

#TODO: Make a swap file
#TODO: Install anydesk, kazam, microsoft teams, meshlab, docker, qgis, caffeine, batcat, wireguard, tmuxinator, poetry, geeqie, fzf, ansible,

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
geeqie \
ruby \
docker-compose-plugin \
fish

# Tmux and tmuxinator
#sudo gem install tmuxinator
# Add tmux package manager
git clone https://github.com/tmux-plugins/tpm ~/.tmux/plugins/tpm

# Pip and ansible
curl -sSL https://bootstrap.pypa.io/get-pip.py -o get-pip.py && python3 get-pip.py --user
python3 -m pip install --user ansible

#thefuck
pip3 install thefuck --user

# podman-compose
pip3 install podman-compose

# Poetry
curl -sSL https://install.python-poetry.org | python3 -

# Fuzzy Find
rm -rf ~/.fzf
git clone --depth 1 https://github.com/junegunn/fzf.git ~/.fzf
~/.fzf/install

# Nerdfont install
curl -sS https://webi.sh/nerdfont | sh

# Starship install
curl -sS https://starship.rs/install.sh | sh

# vim-plug
sh -c 'curl -fLo "${XDG_DATA_HOME:-$HOME/.local/share}"/nvim/site/autoload/plug.vim --create-dirs \
       https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim'

# Podman
#source /etc/os-release
#sudo sh -c "echo 'deb http://download.opensuse.org/repositories/devel:/kubic:/libcontainers:/stable/xUbuntu_${VERSION_ID}/ /' > /etc/apt/sources.list.d/devel:kubic:libcontainers:stable.list"
#wget -nv https://download.opensuse.org/repositories/devel:kubic:libcontainers:stable/xUbuntu_${VERSION_ID}/Release.key -O- | sudo apt-key add -
#sudo apt-get update -qq -y
#sudo apt-get -qq --yes install podman


mkdir -p ${DIR}/../.vim/bundle
mkdir -p ${DIR}/../.config/fish/

# Link dotfiles
ln -s ${DIR}/3.3a.tmux.conf ${DIR}/../.tmux.conf
ln -s ${DIR}/.vimrc ${DIR}/../.vimrc
ln -s ${DIR}/.vimrc ${DIR}/../.vim/init.vim
ln -s ${DIR}/config.fish ${DIR}/.config/fish/config.fish


# Install vim theme solarized
source ${DIR}/install_pathogen.sh
source ${DIR}/install_solarized.sh

cd ${DIR}/../.vim/bundle
#git clone https://github.com/yhat/vim-docstring.git

cd $DIR

# setup default git
git config --global user.email "adam.romlein@kitware.com"
git config --global user.name  "Adam Romlein"
