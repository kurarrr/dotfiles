alias dcp="docker compose"
alias zshconf="vim $HOME/.zshrc"
alias zshrel="source $HOME/.zshrc"

alias k="kubectl"
alias kd="kubectl describe"

alias gcurl='curl --header "Authorization: Bearer $(gcloud auth print-identity-token)"'
alias jqless='jq '.' -C | less -R'

export GOPATH="$HOME/go"

export PATH="$PATH:$HOME/bin:/usr/local/bin:/usr/bin:/sbin:/opt/local/bin/\
:$HOME/.pyenv/bin\
:$HOME/.poetry/bin\
:$GOPATH/bin\
"

# Use gsed, gawk, gfind, core utils as default
PATH="/usr/local/opt/coreutils/libexec/gnubin\
:/usr/local/opt/gnu-sed/libexec/gnubin\
:/usr/local/opt/gawk/libexec/gnubin/
:/usr/local/opt/findutils/libexec/gnubin\
:/usr/local/opt/grep/libexec/gnubin\
:$PATH"
MANPATH="/usr/local/opt/coreutils/libexec/gnuman\
:/usr/local/opt/gnu-sed/libexec/gnuman\
:/usr/local/opt/gawk/libexec/gnuman\
:/usr/local/opt/findutils/libexec/gnuman\
:/usr/local/opt/grep/libexec/gnuman\
:$MANPATH"

[[ -f '/usr/local/Caskroom/google-cloud-sdk/latest/google-cloud-sdk/path.zsh.inc' ]] && source "/usr/local/Caskroom/google-cloud-sdk/latest/google-cloud-sdk/path.zsh.inc"
[[ -f '/usr/local/Caskroom/google-cloud-sdk/latest/google-cloud-sdk/completion.zsh.inc' ]] &&
  source "/usr/local/Caskroom/google-cloud-sdk/latest/google-cloud-sdk/completion.zsh.inc"

function current_gcp_project() {
  if [[ -n $CLOUDSDK_ACTIVE_CONFIG_NAME ]]; then
    echo ${CLOUDSDK_ACTIVE_CONFIG_NAME}
  fi
}

PROMPT=$(
  cat <<EOL
%{$fg_bold[green]%}%n@%m %{$fg[blue]%}%D{[%X]} %{$reset_color%}%{$fg[white]%}[%~]%{$reset_color%}
%{$fg[blue]%}->%{$fg_bold[blue]%} %#%{$reset_color%} 
EOL
)

export LESS='-g -i -M -R -W -z-4 -x4'

if command -v pyenv >/dev/null; then
  eval "$(pyenv init --path)"
  eval "$(pyenv virtualenv-init -)"
fi

[[ -s "$HOME/.gvm/scripts/gvm" ]] && source "$HOME/.gvm/scripts/gvm"

export CPLUS_INCLUDE_PATH="$CPLUS_INCLUDE_PATH:$HOME/.csrc:/usr/local/Cellar/boost/1.70.0/include"
export LDFLAGS="-L/usr/local/opt/openblas/lib"
export CPPFLAGS="-I/usr/local/opt/openblas/include"

# For mount command in docker
export DOCKER_BUILDKIT=1
export COMPOSE_DOCKER_CLI_BUILD=1

export CLOUDSDK_PYTHON_SITEPACKAGES=1

export USE_GKE_GCLOUD_AUTH_PLUGIN=True

export ZSH="$HOME/.oh-my-zsh"
export ZSH_THEME="candy"

plugins=(
  git brew gem pyenv kubectl gcloud
)

source $ZSH/oh-my-zsh.sh

if command -v kubectl >/dev/null 2>&1; then
  source <(kubectl completion zsh)
fi

# You may need to manually set your language environment
export LANG=ja_JP.UTF-8
export LC_ALL=ja_JP.UTF-8

# 日本語ファイル名を表示可能にする
setopt print_eight_bit

# cdなしでディレクトリ移動
setopt auto_cd

# ビープ音の停止
setopt no_beep

# ビープ音の停止(補完時)
setopt nolistbeep

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

export EDITOR="vim"

if command -v direnv >/dev/null 2>&1; then
  eval "$(direnv hook zsh)"
fi

plugins=(git docker docker-compose gcloud kubectl)

source $ZSH/oh-my-zsh.sh

gcsavro() {
  for f in $(gsutil ls $1); do
    gsutil cat "$f" | avro-tools tojson - | jq
  done
}

[ -f ~/.fzf.zsh ] && source ~/.fzf.zsh

. $(brew --prefix)/etc/profile.d/z.sh
fzf-z-search() {
  local res=$(z | sort -rn | cut -c 12- | fzf)
  if [ -n "$res" ]; then
    BUFFER+="cd $res"
    zle accept-line
  else
    return 1
  fi
}

zle -N fzf-z-search
bindkey '^f' fzf-z-search

function ghql() {
  local src=$(ghq list | fzf --preview "/bin/ls -laTp $(ghq root)/{} | tail -n+4 | awk '{print \$9\"/\"\$6\"/\"\$7 \" \" \$10}'")
  cd $(ghq root)/$src
}

function gitc() {
  local branches branch
  branches=$(git branch | sed -e 's/\(^\* \|^  \)//g' | cut -d " " -f 1) &&
    branch=$(echo "$branches" | fzf --preview "git log --graph --full-history --color --first-parent {}") &&
    git checkout $(echo "$branch")
}

export GIT_COMPLETION_CHECKOUT_NO_GUESS=1
