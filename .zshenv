#zmodload zsh/zprof && zprof
[[ -s "$HOME/.profile" ]] && source "$HOME/.profile" # Load the default .profile
export PATH=/usr/local/bin:$PATH
export PATH="$HOME/.rbenv/bin:$PATH"
if which rbenv > /dev/null; then eval "$(rbenv init -)"; fi
export EDITOR=vim
export LANG=ja_JP.UTF-8
export KCODE=u

p=$PATH;PATH=;/usr/libexec/path_helper -s >> ~/.zprofile;PATH=$p

## $B=EJ#%Q%9$rEPO?$7$J$$(B
typeset -U path cdpath fpath manpath

### sudo$BMQ$N(Bpath$B$r@_Dj(B
typeset -xT SUDO_PATH sudo_path
typeset -U sudo_path
sudo_path=({/usr/local,/usr,}/sbin(N-/))
### path$B$r@_Dj(B
path=(~/bin(N-/) /usr/local/bin(N-/) ${path})

###lsColor###
export LSCOLORS=Exfxcxdxbxegedabagacad
export LS_COLORS='di=01;34:ln=01;35:so=01;32:ex=01;31:bd=46;34:cd=43;34:su=41;30:sg=46;30:tw=42;30:ow=43;30'
export LS_COLORS='di=01;34:ln=01;35:so=01;32:ex=01;31:bd=46;34:cd=43;34:su=41;30:sg=46;30:tw=42;30:ow=43;30'
export ZLS_COLORS=$LS_COLORS
export CLICCOLOR=true
zstyle ':completion:*:default' list-colors ${(s.:.)LS_COLORS}
#==============

###userColor###
autoload -U colors; colors

if [ ${UID} -eq 0 ]; then
	tmp_prompt="%B%U${tmp_prompt}%u%b"
	tmp_prompt2="%B%U${tmp_prompt2}%u%b"
	tmp_rprompt="%B%U${tmp_rprompt}%u%b"
	tmp_sprompt="%B%U${tmp_sprompt}%u%b"
fi
#==============

###currentDirectry###
autoload colors
colors

PROMPT="
 %{${fg[purple]}%}%~%{${reset_color}%}
 [%n]$ "
 PROMPT2='[%n]> '
# http://mollifier.mit-license.org/

# $B?'$r;HMQ=PMh$k$h$&$K$9$k(B
autoload -Uz colors
colors

# $B%R%9%H%j$N@_Dj(B
HISTFILE=~/.zsh_history
HISTSIZE=1000000
SAVEHIST=1000000
setopt bang_hist
setopt extended_history


PROMPT="
%(?.%{${fg[green]}%}.%{${fg[red]}%})[%n@%m] %~%{${reset_color}%}
 < "
RPROMPT='%{$fg[cyan]%}[%~]%{${reset_color%}'
SPROMPT="%{${fg[yellow]}%}  > %r ? [ynae]:%{${reset_color}%}"

# $BC18l$N6h@Z$jJ8;z$r;XDj$9$k(B
autoload -Uz select-word-style
select-word-style default
# $B$3$3$G;XDj$7$?J8;z$OC18l6h@Z$j$H$_$J$5$l$k(B
# / $B$b6h@Z$j$H07$&$N$G!"(B^W $B$G%G%#%l%/%H%j#1$DJ,$r:o=|$G$-$k(B
zstyle ':zle:*' word-chars " /=;@:{},|"
zstyle ':zle:*' word-style unspecified

########################################
# $BJd40(B
# $BJd405!G=$rM-8z$K$9$k(B
autoload -Uz compinit
compinit

#Shift-ctr$B$GJd40$N%P%C%/(B
bindkey "^[[Z" reverse-menu-complete

#$BLp0u%$%s%?!<%U%'%$%9(B
zstyle ':completion:*' menu select

#$BJd40$G>.J8;z$G$bBgJ8;z$K%^%C%A$5$;$k(B
zstyle ':completion:*' matcher-list 'm:{a-z}={A-Z}'

# ../ $B$N8e$O:#$$$k%G%#%l%/%H%j$rJd40$7$J$$(B
zstyle ':completion:*' ignore-parents parent pwd ..

# sudo $B$N8e$m$G%3%^%s%IL>$rJd40$9$k(B
zstyle ':completion:*:sudo:*' command-path /usr/local/sbin /usr/local/bin \
	/usr/sbin /usr/bin /sbin /bin /usr/X11R6/bin

# ps $B%3%^%s%I$N%W%m%;%9L>Jd40(B
zstyle ':completion:*:processes' command 'ps x -o pid,s,args'


########################################
# vcs_info
autoload -Uz vcs_info
autoload -Uz add-zsh-hook

zstyle ':vcs_info:*' formats '%F{green}(%s)-[%b]%f'
zstyle ':vcs_info:*' actionformats '%F{red}(%s)-[%b|%a]%f'

function _update_vcs_info_msg() {
   LANG=en_US.UTF-8 vcs_info
#    RPROMPT="${vcs_info_msg_0_}"
}
add-zsh-hook precmd _update_vcs_info_msg


#######################################
# $B%*%W%7%g%s(B
# $BF|K\8l%U%!%$%kL>$rI=<(2DG=$K$9$k(B
#
setopt print_eight_bit

# beep $B$rL58z$K$9$k(B
setopt no_beep

# $B%U%m!<%3%s%H%m!<%k$rL58z$K$9$k(B
setopt no_flow_control

# '#' $B0J9_$r%3%a%s%H$H$7$F07$&(B
setopt interactive_comments

# $B%G%#%l%/%H%jL>$@$1$G(Bcd$B$9$k(B
setopt auto_cd

# cd $B$7$?$i<+F0E*$K(Bpushd$B$9$k(B
setopt auto_pushd
# $B=EJ#$7$?%G%#%l%/%H%j$rDI2C$7$J$$(B
setopt pushd_ignore_dups

# $BF1;~$K5/F0$7$?(Bzsh$B$N4V$G%R%9%H%j$r6&M-$9$k(B
setopt share_history

# $BF1$8%3%^%s%I$r%R%9%H%j$K;D$5$J$$(B
setopt hist_ignore_all_dups

# $B%9%Z!<%9$+$i;O$^$k%3%^%s%I9T$O%R%9%H%j$K;D$5$J$$(B
setopt hist_ignore_space

# $B%R%9%H%j$KJ]B8$9$k$H$-$KM>J,$J%9%Z!<%9$r:o=|$9$k(B
setopt hist_reduce_blanks

# $B9b5!G=$J%o%$%k%I%+!<%IE83+$r;HMQ$9$k(B
setopt extended_glob

#$B$"$$$^$$Jd40(B
setopt correct

#PCRE$B@55,I=8=(B
setopt re_match_pcre

#$BI=<($NEY$KI>2A$HCV49$r9T$&(B
setopt prompt_subst

#######################################
# $B%-!<%P%$%s%I(B

# ^R $B$GMzNr8!:w$r$9$k$H$-$K(B * $B$G%o%$%k%I%+!<%I$r;HMQ=PMh$k$h$&$K$9$k(B
bindkey '^R' history-incremental-pattern-search-backward

########################################
# $B%(%$%j%"%9(B

alias la='ls -a'
alias ll='ls -l'

alias rm='rm -i'
alias cp='cp -i'
alias mv='mv -i'

alias mkdir='mkdir -p'
alias dxrp='dxrp5 --nojruby run'
alias rp5='rp5 --nojruby run'

# sudo $B$N8e$N%3%^%s%I$G%(%$%j%"%9$rM-8z$K$9$k(B
alias sudo='sudo '

# $B%0%m!<%P%k%(%$%j%"%9(B
alias -g L='| less'
alias -g G='| grep'

#######################################
# Color
#######################################
#$B?'$N@_Dj(B
export LSCOLORS=gxfxcxdxbxegedabagacad
export LS_COLORS='di=32:ln=35:so=32:pi=33:ex=31:bd=46;34:cd=43;34:su=41;30:sg=46;30:tw=42;30:ow=43;30'
zstyle ':completion:*' list-colors \
'di=36' 'ln=35' 'so=32' 'ex=31' 'bd=46;34' 'cd=43;34'

export CLICOLOR=1
alias ls='ls -G -F'

######################################
#rbenv PATH
#####################################
export PATH="$HOME/.rbenv/bin:$PATH"
eval "$(rbenv init -)"
export PATH=/usr/local/bin:$PATH
export PATH=$HOME/.rbenv/bin:$PATH
eval "$(rbenv init - zsh)"
export CC=/usr/bin/gcc-4.2

alias javac='javac -J-Dfile.encoding=UTF8'

