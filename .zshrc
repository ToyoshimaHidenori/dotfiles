#!/bin/sh
export LANG=ja_JP.UTF-8

# 何か操作を行ったときに呼び出されるhook関数を登録できる
autoload -Uz add-zsh-hook
#vim キーバインド
bindkey -v


###############################################
# コマンド履歴設定
HISTFILE=~/.zsh_history
HISTSIZE=1000000
SAVEHIST=1000000
setopt hist_ignore_all_dups  # 重複するコマンド行は古い方を削除
setopt hist_ignore_dups      # 直前と同じコマンドラインはヒストリに追加しない
setopt append_history        # 履歴を追加 (毎回 .zsh_history を作るのではなく)
setopt inc_append_history    # 履歴をインクリメンタルに追加
setopt hist_no_store         # historyコマンドは履歴に登録しない
setopt share_history         # 同時に起動したzshの間でヒストリを共有する
setopt hist_reduce_blanks    # ヒストリに保存するときに余分なスペースを削除する

###############################################
# プロンプト設定
# 色を使用出来るようにする
autoload -Uz colors
colors

setopt prompt_subst
typeset -A emoji
emoji[git]="🍀"
emoji[git_changed]="🍣"
emoji[git_untracked]="🚧"
emoji[git_clean]="🌟"

function _vcs_git_indicator () {
  typeset -A git_info
  local git_indicator git_status
  git_status=("${(f)$(git status --porcelain --branch 2> /dev/null)}")
  (( $? == 0 )) && {
    git_info[branch]="${${git_status[1]}#\#\# }"
    shift git_status
    git_info[changed]=${#git_status:#\?\?*}
    git_info[untracked]=$(( $#git_status - ${git_info[changed]} ))
    git_info[clean]=$(( $#git_status == 0 ))

    git_indicator=("${emoji[git]}  %{%F{green}%}${git_info[branch]}%{%f%}")
    (( ${git_info[clean]}     )) && git_indicator+=("${emoji[git_clean]}")
    (( ${git_info[changed]}   )) && git_indicator+=("${emoji[git_changed]}  %{%F{red}%}${git_info[changed]} changed%{%f%}")
    (( ${git_info[untracked]} )) && git_indicator+=("${emoji[git_untracked]} %{%F{yellow}%}${git_info[untracked]} untracked%{%f%}")
  }
  _vcs_git_indicator="${git_indicator}"
}
add-zsh-hook precmd _vcs_git_indicator

#for pure prompt
fpath+=$HOME/.zsh/pure
autoload -U promptinit; promptinit
prompt pure

function {
local check="%(?.✨.😰) "
#PROMPT="${check}[%F{cyan}%*%F{reset_color}]:%F{yellow}%~%F{reset_color} %# "
RPROMPT='$_vcs_git_indicator'
}

# 単語の区切り文字を指定する
autoload -Uz select-word-style
select-word-style default
# ここで指定した文字は単語区切りとみなされる
# / も区切りと扱うので、^W でディレクトリ１つ分を削除できる
zstyle ':zle:*' word-chars " /=;@:{},|"
zstyle ':zle:*' word-style unspecified

# git 補完
autoload -Uz compinit && compinit


###########################################
# オプション
# 日本語ファイル名を表示可能にする
setopt print_eight_bit

# beep を無効にする
setopt no_beep

# ディレクトリ名だけでcdする
setopt auto_cd

# cd したら自動的にpushdする
setopt auto_pushd


##########################################
# エイリアス
alias la='ls -a'
alias ll='ls -l'
alias rm='rm -i'
alias cp='cp -i'
alias mv='mv -i'
alias g="git branch; git status"
alias mkdir='mkdir -p'
alias la="ls -a"

###########################################
# パス設定 
export PATH="$HOME/.jenv/bin:$PATH"
eval "$(jenv init -)"
export PYENV_ROOT="$HOME/.pyenv"
export PATH="$PYENV_ROOT/bin:$PATH"
eval "$(pyenv init -)"
export PATH="/usr/local/opt/bison/bin:$PATH"
export PATH="/usr/local/opt/gettext/bin:$PATH"
export PATH="/usr/local/opt/libxml2/bin:$PATH"