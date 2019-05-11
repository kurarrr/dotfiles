alias atc='atcoder-tools'
alias tes='g++ main.cpp && atc test'
alias sub='g++ main.cpp && atc submit'
alias dcp='docker-compose'

export PATH=$HOME/bin:/usr/local/bin:$PATH
export PATH="$PATH:/usr/sbin"
export PATH="$PATH:/sbin"

export PYENV_ROOT="$HOME/.pyenv"                                                           
export PATH="$PYENV_ROOT/bin:$PATH"

# eval "$(pyenv init -)"

export NODE_PATH=/usr/local/lib/node_modules
export PATH="/Library/TeX/texbin:$PATH"
export PATH="$HOME/.rbenv/bin:$PATH"

# if which rbenv > /dev/null; then eval "$(rbenv init -)"; fi

export CPLUS_INCLUDE_PATH=$CPLUS_INCLUDE_PATH:/Users/kurarrr/.csrc

export ZSH=/Users/kurarrr/.oh-my-zsh
ZSH_THEME="candy"

plugins=(
  git brew brew-cask cdd gem rbenv pyenv
)

source $ZSH/oh-my-zsh.sh

export PATH="/usr/local/sbin:$PATH"

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

[[ -s "/Users/kurarrr/.gvm/scripts/gvm" ]] && source "/Users/kurarrr/.gvm/scripts/gvm"
