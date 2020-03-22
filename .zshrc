alias atc='atcoder-tools'
alias tes='g++ main.cpp && atc test'
alias sub='g++ main.cpp && atc submit'
alias dcp='docker-compose'
alias dcs='docker-sync'
alias tunnel-on='sudo networksetup -setsocksfirewallproxystate Wi-Fi on && ssh tunnel -N'
alias tunnel-off='sudo networksetup -setsocksfirewallproxystate Wi-Fi off'
eval $(thefuck --alias)

export PATH="$PATH:$HOME/bin:/usr/local/bin:/usr/bin:/sbin"

export PATH=$PATH:`npm bin -g`

export PATH="$PATH:$HOME/.pyenv/bin"
eval "$(pyenv init -)"
eval "$(pyenv virtualenv-init -)"

export NODENV_ROOT="$HOME/.nodenv"
export PATH="$NODENV_ROOT/bin:$PATH"
eval "$(nodenv init -)"

export PATH="$HOME/.rbenv/bin:$PATH"
eval "$(rbenv init -)"
export RUBY_CONFIGURE_OPTS="--with-openssl-dir=$(brew --prefix openssl@1.1)"

# for php composer
export PATH="$PATH:$HOME/.composer/vendor/bin"

[[ -s "/Users/kurarrr/.gvm/scripts/gvm" ]] && source "/Users/kurarrr/.gvm/scripts/gvm"

export PATH="$PATH:$HOME/flutter/bin"

export PATH="/Library/TeX/texbin:$PATH"

export CPLUS_INCLUDE_PATH=$CPLUS_INCLUDE_PATH:/Users/kurarrr/.csrc
export CPLUS_INCLUDE_PATH=$CPLUS_INCLUDE_PATH:/usr/local/Cellar/boost/1.70.0/include

export LDFLAGS="-L/usr/local/opt/openblas/lib"
export CPPFLAGS="-I/usr/local/opt/openblas/include"

bindkey "^R" history-incremental-pattern-search-backward
export ZSH=/Users/kurarrr/.oh-my-zsh
ZSH_THEME="candy"

plugins=(
  git brew gem rbenv pyenv
)

source $ZSH/oh-my-zsh.sh

# You may need to manually set your language environment
export LANG=ja_JP.UTF-8

# 日本語ファイル名を表示可能にする
setopt print_eight_bit

# cdなしでディレクトリ移動
setopt auto_cd

# ビープ音の停止
setopt no_beep

# ビープ音の停止(補完時)
setopt nolistbeep

# cd -<tab>で以前移動したディレクトリを表示
setopt auto_pushd

# ヒストリ(履歴)を保存、数を増やす
HISTFILE=~/.zsh_history
HISTSIZE=100000
SAVEHIST=100000

# 同時に起動したzshの間でヒストリを共有する
setopt share_history

# 直前と同じコマンドの場合は履歴に追加しない
setopt hist_ignore_dups

# 同じコマンドをヒストリに残さない
setopt hist_ignore_all_dups

# スペースから始まるコマンド行はヒストリに残さない
setopt hist_ignore_space

# ヒストリに保存するときに余分なスペースを削除する
setopt hist_reduce_blanks

bindkey -v
bindkey '^R' history-incremental-search-backward

# zsh-completionsの設定
# fpath=(/path/to/homebrew/share/zsh-completions $fpath)
# autoload -U compinit
# compinit -u

# Preferred editor for local and remote sessions
# if [[ -n $SSH_CONNECTION ]]; then
#   export EDITOR='vim'
# else
#   export EDITOR='mvim'
# fi

# Compilation flags
# export ARCHFLAGS="-arch x86_64"
# ssh
# export SSH_KEY_PATH="~/.ssh/rsa_id"

# Set personal aliases, overriding those provided by oh-my-zsh libs,
# plugins, and themes. Aliases can be placed here, though oh-my-zsh
# users are encouraged to define aliases within the ZSH_CUSTOM folder.
# For a full list of active aliases, run `alias`.
#
# Example aliases
# alias zshconfig="mate ~/.zshrc"
# alias ohmyzsh="mate ~/.oh-my-zsh"

