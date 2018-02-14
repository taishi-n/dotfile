export EDITOR=vim
export LANG=ja_JP.UTF-8
export KCODE=u

export PATH="$PATH:$HOME/.rvm/bin" # Add RVM to PATH for scripting

p=$PATH;PATH=;/usr/libexec/path_helper -s >> ~/.zprofile;PATH=$p

## 重複パスを登録しない
typeset -U path cdpath fpath manpath

### sudo用のpathを設定
typeset -xT SUDO_PATH sudo_path
typeset -U sudo_path
sudo_path=({/usr/local,/usr,}/sbin(N-/))
### pathを設定
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

###viAlias###
alias vi='/usr/local/bin/vim'
#==============

###currentDirectry###
autoload colors
colors

PROMPT="
 %{${fg[purple]}%}%~%{${reset_color}%}
 [%n]$ "
 PROMPT2='[%n]> '
# http://mollifier.mit-license.org/

# 色を使用出来るようにする
autoload -Uz colors
colors

# ヒストリの設定
HISTFILE=~/.zsh_history
HISTSIZE=1000000
SAVEHIST=1000000
setopt bang_hist
setopt extended_history

# プロンプトの表示設定
PROMPT="
%(?.%{${fg[green]}%}.%{${fg[red]}%})[%n@%m] %~%{${reset_color}%}
 < "
RPROMPT='%{$fg[cyan]%}[%~]%{${reset_color%}'
SPROMPT="%{${fg[yellow]}%}  > %r ? [ynae]:%{${reset_color}%}"


# 単語の区切り文字を指定する
autoload -Uz select-word-style
select-word-style default
# ここで指定した文字は単語区切りとみなされる
# / も区切りと扱うので、^W でディレクトリ１つ分を削除できる
zstyle ':zle:*' word-chars " /=;@:{},|"
zstyle ':zle:*' word-style unspecified

########################################
# 補完
# 補完機能を有効にする
autoload -Uz compinit
compinit

#Shift-ctrで補完のバック
bindkey "^[[Z" reverse-menu-complete

#矢印インターフェイス
zstyle ':completion:*' menu select

#補完で小文字でも大文字にマッチさせる
zstyle ':completion:*' matcher-list 'm:{a-z}={A-Z}'

# ../ の後は今いるディレクトリを補完しない
zstyle ':completion:*' ignore-parents parent pwd ..

# sudo の後ろでコマンド名を補完する
zstyle ':completion:*:sudo:*' command-path /usr/local/sbin /usr/local/bin \
	/usr/sbin /usr/bin /sbin /bin /usr/X11R6/bin

# ps コマンドのプロセス名補完
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
# オプション
# 日本語ファイル名を表示可能にする
#
setopt print_eight_bit

# beep を無効にする
setopt no_beep

# フローコントロールを無効にする
setopt no_flow_control

# '#' 以降をコメントとして扱う
setopt interactive_comments

# ディレクトリ名だけでcdする
setopt auto_cd

# cd したら自動的にpushdする
setopt auto_pushd
# 重複したディレクトリを追加しない
setopt pushd_ignore_dups

# 同時に起動したzshの間でヒストリを共有する
setopt share_history

# 同じコマンドをヒストリに残さない
setopt hist_ignore_all_dups

# スペースから始まるコマンド行はヒストリに残さない
setopt hist_ignore_space

# ヒストリに保存するときに余分なスペースを削除する
setopt hist_reduce_blanks

# 高機能なワイルドカード展開を使用する
setopt extended_glob

#あいまい補完
setopt correct

#PCRE正規表現
setopt re_match_pcre

#表示の度に評価と置換を行う
setopt prompt_subst

#######################################
# キーバインド

# ^R で履歴検索をするときに * でワイルドカードを使用出来るようにする
bindkey '^R' history-incremental-pattern-search-backward

########################################
# エイリアス

alias la='ls -a'
alias ll='ls -l'

alias rm='rm -i'
alias cp='cp -i'
alias mv='mv -i'

alias mkdir='mkdir -p'
alias dxrp='dxrp5 --nojruby run'
alias rp5='rp5 --nojruby run'
# alias ls='ls -GFlt'

# sudo の後のコマンドでエイリアスを有効にする
alias sudo='sudo '

# グローバルエイリアス
alias -g L='| less'
alias -g G='| grep'

#######################################
# Color
#######################################
#色の設定
export LSCOLORS=gxfxcxdxbxegedabagacad
export LS_COLORS='di=32:ln=35:so=32:pi=33:ex=31:bd=46;34:cd=43;34:su=41;30:sg=46;30:tw=42;30:ow=43;30'
zstyle ':completion:*' list-colors \
'di=36' 'ln=35' 'so=32' 'ex=31' 'bd=46;34' 'cd=43;34'

export CLICOLOR=1

######################################
#rbenv PATH
#####################################
export PATH="$HOME/.rbenv/bin:$PATH"
eval "$(rbenv init -)"
export PATH=/usr/local/bin:$PATH
export PATH=$HOME/.rbenv/bin:$PATH
eval "$(rbenv init - zsh)"
export CC=/usr/bin/gcc

####################################
#pyenv PATH
###################################
#pyenvさんに~/.pyenvではなく/usr/local/var/pyenvを使うようにお願いする
export PYENV_ROOT=/usr/local/var/pyenv
#pyenvさんに自動補完機能を提供してもらう
if which pyenv > /dev/null; then eval "$(pyenv init -)"; fi
export CC=/usr/bin/gcc

#jman
alias jman='env LANG=ja_JP.UTF-8 man'

#if (which zprof > /dev/null) ;then
#	zprof | less
#fi

source ~/.rbenv_init #rbenvのrehash無効化。ときどき自分でrbenv rehashしてあげよう

#Hadoop のエイリアス
alias hstart="/usr/local/Cellar/hadoop/2.8.0/sbin/start-dfs.sh;/usr/local/Cellar/hadoop/2.8.0/sbin/start-yarn.sh"
alias hstop="/usr/local/Cellar/hadoop/2.8.0/sbin/stop-yarn.sh;/usr/local/Cellar/hadoop/2.8.0/sbin/stop-dfs.sh"

# Mycommands
alias urlenc='find -E . -regex "^.+%[0-9A-Z][0-9A-Z]+.*" -exec bash -c "mv {} \`echo {} | nkf --url-input \`" \;'

# git設定
RPROMPT="%{${fg[blue]}%}[%~]%{${reset_color}%}"
autoload -Uz vcs_info
setopt prompt_subst
zstyle ':vcs_info:git:*' check-for-changes true
zstyle ':vcs_info:git:*' stagedstr "%F{yellow}!"
zstyle ':vcs_info:git:*' unstagedstr "%F{red}+"
zstyle ':vcs_info:*' formats "%F{green}%c%u[%b]%f"
zstyle ':vcs_info:*' actionformats '[%b|%a]'
precmd () { vcs_info }
RPROMPT=$RPROMPT'${vcs_info_msg_0_}'
