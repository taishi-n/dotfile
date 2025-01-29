# Fish char settings
set fish_ambiguous_width 1

# PATH
# EXAMPLE: set -x PATH /usr/local/bin $PATH
set -x PATH /opt/homebrew/bin $PATH
set -x PATH /opt/local/bin $PATH
set -x PATH /opt/local/sbin $PATH
set -x PATH $HOME/.nodebrew/current/bin $PATH

# for python with uv
source $HOME/.local/bin/env.fish

# Alias
alias ls='env COLUMNS=150 eza --icons --group-directories-first'
alias vi=(which nvim)
alias rm='trash'
alias memo='vi ~/Downloads/memo.md'
alias mv='mv -in'
alias vitex='NVIM_LISTEN_ADDRESS=/tmp/nvimsocket nvim'
alias g++='g++ -std=gnu++17'

# Abbreviations
abbr --add gits 'git status'
abbr --add phd "cd ~/onolab/thesis.nosync/Nakashima2024PhDThesis/"
abbr --add spl "cd ~/onolab/publications.nosync/Nakashima2023SPL/"
abbr --add diary --set-cursor=1 'vi ~/diary/(date 1 "+%Y-%m-%d").md'
abbr --add mtgphd --set-cursor=1 'vi ~/onolab/meeting/doctor/1'
abbr --add todo 'vi ~/diary/00_todo.md'

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

# gpg
set -x GPG_TTY (tty)

# opam configuration
source /Users/taishi/.opam/opam-init/init.fish > /dev/null 2> /dev/null; or true

# starship
source (/opt/homebrew/bin/starship init fish --print-full-init | psub)

eval "$(/opt/homebrew/bin/brew shellenv)"
