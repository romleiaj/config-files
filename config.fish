if status is-interactive
    # Commands to run in interactive sessions can go here
end

alias ll='ls -alF'
alias la='ls -A'
alias l='ls -CF'
alias dk='docker container kill $(docker container ls -q)'
alias dls='docker container ls'
alias tk='tmux kill-server'
alias gp='git pull --ff-only'
alias ga='git add'
alias gst='git status'
alias ccy='catkin clean -y'
alias cb='catkin build'
alias cnt='ls -l $1 | wc -l'
alias cp='rsync -avH'
alias rsync='rsync -avH --progress'
alias du='du -ahd 1 | sort -h'
alias mux="tmuxinator"
alias ssh='ssh -A'
alias podman-compose='podman-compose --podman-run-args="--group-add keep-groups"'
alias cat='bat --paging=never --style=plain'
alias vim='nvim'
alias python='python3'
export MANPAGER="sh -c 'col -bx | bat -l man -p'"

starship init fish | source

thefuck --alias | source

zoxide init fish | source

# Generated for envman. Do not edit.
test -s "$HOME/.config/envman/load.fish"; and source "$HOME/.config/envman/load.fish"
