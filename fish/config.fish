# Fish git prompt
set __fish_git_prompt_showdirtystate 'yes'
set __fish_git_prompt_showstashstate 'yes'
set __fish_git_prompt_showuntrackedfiles 'yes'
set __fish_git_prompt_showupstream 'yes'
set __fish_git_prompt_color_branch yellow
set __fish_git_prompt_color_upstream_ahead green
set __fish_git_prompt_color_upstream_behind red

# Status Chars
set __fish_git_prompt_char_dirtystate '⚡︎'
set __fish_git_prompt_char_stagedstate '→'
set __fish_git_prompt_char_untrackedfiles '⚠︎ '
set __fish_git_prompt_char_stashstate '↩ '
set __fish_git_prompt_char_upstream_ahead '+'
set __fish_git_prompt_char_upstream_behind '-'

# Alias
alias vi (which nvim)

# PATH
# EXAMPLE: set -x PATH /usr/local/bin $PATH
#set -x PATH $HOME/.rvm/bin $PATH # Add RVM to PATH for scripting
set -x PATH $HOME/.rbenv/bin $PATH
rbenv init - | source
set -x PATH /usr/local/bin $PATH
set -x PATH /home/linuxbrew/.linuxbrew/bin $PATH
set -g fish_user_paths "/usr/local/sbin" $fish_user_paths

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

function tex-gitignore
   echo "*.aux" >> .gitignore
   echo "*.dvi" >> .gitignore
   echo "*.fdb_latexmk" >> .gitignore
   echo "*.fls" >> .gitignore
   echo "*.log" >> .gitignore
   echo "*.pdf" >> .gitignore
   echo "*.synctex.gz" >> .gitignore
   echo "*.DS_Store" >> .gitignore
end

set os (uname)
if test $os = Linux
   alias open xdg-open
end

# pyenv setting
set -x PYENV_ROOT $HOME/.pyenv
#set -x PATH $HOME/.pyenv/bin $PATH
#set -x PATH $PYENV_ROOT/bin $PATH
status --is-interactive; and source (pyenv init -|psub)
set -x PATH $HOME/.pyenv/shims $PATH

# go setting
set -x GOPATH $HOME/go
set -x PATH $PATH $GOPATH/bin

# key-bind setting
function fish_user_key_bindings
   fish_vi_key_bindings
   bind -M insert \cf forward-char
end

# The next line updates PATH for the Google Cloud SDK.
if [ -f '/Users/taishi/Downloads/google-cloud-sdk/path.fish.inc' ]; . '/Users/taishi/Downloads/google-cloud-sdk/path.fish.inc'; end
set -x CLOUDSDK_PYTHON $HOME/.pyenv/versions/2.7.15/bin/python $CLOUDSDK_PYTHON
