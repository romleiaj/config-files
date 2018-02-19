# control-a to do stuff
unbind C-b
set -g prefix C-a

# alt-ijkl instead of arrow keys to switch panes
bind -n M-j select-pane -L
bind -n M-l select-pane -R
bind -n M-i select-pane -U
bind -n M-k select-pane -D

# background green when active
set-window-option -g window-status-current-bg green

# enable activity alerts
setw -g monitor-activity on
set -g visual-activity on

# easier to remember pane splitting
bind \ split-window -h # Split panes horizontal
bind - split-window -v # Split panes vertically

# Resizing pane to alt-arrow keys
bind -n M-Left resize-pane -L
bind -n M-Right resize-pane -R
bind -n M-Up resize-pane -U
bind -n M-Down resize-pane -D

# rename is now C-a r then enter name
bind-key r command-prompt 'rename-window %%'
