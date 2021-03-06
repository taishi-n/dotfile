# Fish git prompt
# set __fish_git_prompt_showdirtystate 'yes'
# set __fish_git_prompt_showstashstate 'yes'
# set __fish_git_prompt_showuntrackedfiles 'yes'
# set __fish_git_prompt_showupstream 'yes'
# set __fish_git_prompt_color_branch yellow
# set __fish_git_prompt_color_upstream_ahead green
# set __fish_git_prompt_color_upstream_behind red

# # Git status chars
# set __fish_git_prompt_show_informative_status 1
# set __fish_git_prompt_hide_untrackedfiles 1

# set __fish_git_prompt_color_branch magenta --bold
# set __fish_git_prompt_char_cleanstate ' 👍  '
# set __fish_git_prompt_char_conflictedstate ' ⚠️  '
# set __fish_git_prompt_char_dirtystate ' 💩  '
# # set __fish_git_prompt_char_dirtystate ' ☠︎ '
# set __fish_git_prompt_char_invalidstate ' 🤮  '
# set __fish_git_prompt_char_stagedstate ' ⇢ '
# set __fish_git_prompt_char_stashstate ' ↩ '
# set __fish_git_prompt_char_stateseparator ' | '
# set __fish_git_prompt_char_untrackedfiles ' ⚠︎ '
# set __fish_git_prompt_char_upstream_ahead ' ⤴︎ '
# set __fish_git_prompt_char_upstream_behind ' ⤵︎ '
# set __fish_git_prompt_char_upstream_equal ' ✓ '
# set __fish_git_prompt_char_upstream_diverged ' ∞ '

# Alias
alias vi (which nvim)
alias rm rmtrash
alias cdd='cd ~/dotfile'
alias gdiff='git diff'
alias gits='git status'
alias gitc='git commit'
alias gitA='git add -A'
alias memo='nvim ~/Desktop/memo/memo.md'
alias mv='mv -in'
alias vitex='NVIM_LISTEN_ADDRESS=/tmp/nvimsocket nvim'
alias g++='g++ -std=c++11'
alias vc='scutil --nc start TMU-VPN'
alias vd='scutil --nc stop TMU-VPN'

# PATH
# EXAMPLE: set -x PATH /usr/local/bin $PATH
#set -x PATH $HOME/.rvm/bin $PATH # Add RVM to PATH for scripting
set -x PATH /usr/local/bin $PATH
set -x PATH /usr/local/opt/mysql@5.7/bin $PATH
set -x PATH $HOME/.nodebrew/current/bin $PATH
set -x PYTHONPATH $HOME/onolab/pyroomacoustics $PYTHONPATH
set -g fish_user_paths "/usr/local/sbin" $fish_user_paths
set -x PATH $PATH $IRSTLM/bin
set -x PATH ~/Documents/programming/util $PATH
set -x PATH ~/.cargo/bin $PATH

# My commands
function urlenc
find -E . -regex "^.+%[0-9A-Z][0-9A-Z]+.*" -exec bash -c "mv {} `echo {} | nkf --url-input `" \;
end
funcsave urlenc

function replaceTenForComma
sed -i '' -e 's/、/，/g' $argv
end
funcsave replaceTenForComma

function replaceMaruForPeriod
sed -i '' -e 's/。/．/g' $argv
end
funcsave replaceMaruForPeriod

function tex-template
   mkdir fig
   mkdir sections
   touch ref.bib
   touch (basename (pwd)).tex
   touch sections/00-abstract.tex
   touch sections/01-introduction.tex
   touch sections/02-conventional.tex
   touch sections/03-proposed.tex
   touch sections/04-experiment.tex
   touch sections/05-conclusion.tex
   touch sections/06-acknowledgement.tex
end

set os (uname)
if test $os = Linux
   alias open xdg-open
   set -x PATH /home/linuxbrew/.linuxbrew/bin $PATH
end

# rbenv setting
status --is-interactive; and source (rbenv init -|psub)
set -x PATH $HOME/.rbenv/bin $PATH

# pyenv setting
set -x PYENV_ROOT $HOME/.pyenv
#set -x PATH $HOME/.pyenv/bin $PATH
#set -x PATH $PYENV_ROOT/bin $PATH
status --is-interactive; and source (pyenv init -|psub)
set -x PATH $HOME/.pyenv/shims $PATH

# go setting
#set -x GOPATH $HOME/go
#set -x PATH $PATH $GOPATH/bin

# key-bind setting
function fish_user_key_bindings
   fish_vi_key_bindings
   bind -M insert \cf forward-char
   bind \cd delete-char
end

# >>> conda initialize >>>
# !! Contents within this block are managed by 'conda init' !!
eval /Users/taishi/.pyenv/versions/anaconda3-5.3.1/bin/conda "shell.fish" "hook" $argv | source
# <<< conda initialize <<<

# starship init fish | source
set -g fish_user_paths "/usr/local/opt/openssl@1.1/bin" $fish_user_paths
set -g fish_user_paths "/usr/local/opt/llvm/bin" $fish_user_paths
