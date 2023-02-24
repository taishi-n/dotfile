# Fish char settings
set fish_ambiguous_width 1

# Alias
alias ls='env COLUMNS=150 exa --icons --group-directories-first'
alias vi (which nvim)
alias rm trash
alias gits='git status'
alias memo='vi ~/Downloads/memo.md'
alias mv='mv -in'
alias vitex='NVIM_LISTEN_ADDRESS=/tmp/nvimsocket nvim'
alias g++='g++ -std=gnu++17'

# Abbreviations
abbr --add journal "cd ~/onolab/publications/Nakashima2023Journal/"
abbr --add diary 'vi ~/diary/(date "+%Y-%m-%d").md'
abbr --add todo 'vi ~/diary/00_todo.md'

# VPN alias
set -x DEFAULT_VPN "TMU"

# PATH
# EXAMPLE: set -x PATH /usr/local/bin $PATH
set -x PATH /usr/local/bin $PATH
set -x PATH /usr/local/opt/mysql@5.7/bin $PATH
set -x PATH $HOME/.nodebrew/current/bin $PATH
set -g fish_user_paths "/usr/local/sbin" $fish_user_paths
set -x PATH ~/Documents/programming/util $PATH
set -x PATH ~/.cargo/bin $PATH
set -x PATH /opt/local/bin $PATH
set -x PATH /opt/local/sbin $PATH

if test (uname) = Linux
   alias open xdg-open
   set -x PATH /home/linuxbrew/.linuxbrew/bin $PATH
end

# key-bind setting
function fish_user_key_bindings
   fish_vi_key_bindings
   bind -M insert \cf forward-char
   bind \cd delete-char
end

# python
set -Ux PYENV_ROOT $HOME/.pyenv
set -U fish_user_paths $PYENV_ROOT/bin $fish_user_paths
pyenv init - | source

# gpg
set -x GPG_TTY (tty)

# opam configuration
source /Users/taishi/.opam/opam-init/init.fish > /dev/null 2> /dev/null; or true

# exa
set -x EXA_ICON_SPACING 1

# starship
source (/usr/local/bin/starship init fish --print-full-init | psub)

# misc
set -g fish_user_paths "/usr/local/opt/openssl@1.1/bin" $fish_user_paths
set -g fish_user_paths "/usr/local/opt/llvm/bin" $fish_user_paths
