# ls color setting
export LSCOLORS=gxfxcxdxbxegedabagacad

# Fish git prompt
set __fish_git_prompt_showdirtystate 'yes'
set __fish_git_prompt_showstashstate 'yes'
set __fish_git_prompt_showuntrackedfiles 'yes'
set __fish_git_prompt_showupstream 'yes'
set __fish_git_prompt_color_branch yellow
set __fish_git_prompt_color_upstream_ahead green
set __fish_git_prompt_color_upstream_behind red

# Status Chars
set __fish_git_prompt_char_dirtystate '☠︎ '
set __fish_git_prompt_char_stagedstate '→'
set __fish_git_prompt_char_untrackedfiles '⚠︎ '
set __fish_git_prompt_char_stashstate '↩ '
set __fish_git_prompt_char_upstream_ahead '+'
set __fish_git_prompt_char_upstream_behind '-'

# Alias
alias vi (which nvim)
alias rm rmtrash
alias cdd='cd ~/dotfile'
alias gdiff='git diff'
alias gits='git status'
alias gitc='git commit'
alias gitA='git add -A'
alias memo='vi ~/Desktop/memo.md'

# PATH
# EXAMPLE: set -x PATH /usr/local/bin $PATH
#set -x PATH $HOME/.rvm/bin $PATH # Add RVM to PATH for scripting
set -x PATH /usr/local/bin $PATH
set -x PATH /usr/local/opt/mysql@5.7/bin $PATH
set -x PATH $HOME/.nodebrew/current/bin $PATH
set -x PYTHONPATH $HOME/onolab/pyroomacoustics $PYTHONPATH
set -g fish_user_paths "/usr/local/sbin" $fish_user_paths
set -x PATH $HOME/Downloads/kaldi/tools/python $PATH
set -x IRSTLM $HOME/Downloads/kaldi/tools/irstlm
set -x PATH $PATH $IRSTLM/bin

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
   echo "*.bbl" >> .gitignore
   echo "*.blg" >> .gitignore
   echo "*.dvi" >> .gitignore
   echo "*.fdb_latexmk" >> .gitignore
   echo "*.fls" >> .gitignore
   echo "*.log" >> .gitignore
   echo "*.nav" >> .gitignore
   echo "*.out" >> .gitignore
   echo "*.snm" >> .gitignore
   echo "*.toc" >> .gitignore
   echo "*.pdf" >> .gitignore
   echo "*.synctex.gz" >> .gitignore
end

function tex-template
   mkdir fig
   mkdir sections
   touch ref.bib
   touch (basename (pwd)).tex
   touch sections/abstract.tex
   touch sections/introduction.tex
   touch sections/conventional.tex
   touch sections/proposed.tex
   touch sections/experiment.tex
   touch sections/conclusion.tex
   touch sections/acknowledgement.tex
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

# conda setting
source (conda info --root)/etc/fish/conf.d/conda.fish
