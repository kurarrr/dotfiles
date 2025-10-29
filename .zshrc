# Aliases
alias dcp="docker compose"
alias zshconf="vim $HOME/.zshrc"
alias zshrel="source $HOME/.zshrc"
alias k="kubectl"
alias kg="kubectl get"
alias kd="kubectl describe"
alias ktx="kubectx"

[ -f ~/.fzf.zsh ] && source ~/.fzf.zsh
eval "$(direnv hook zsh)"

alias gcurl='curl --header "Authorization: Bearer $(gcloud auth print-identity-token)"'
alias jqless='jq '.' -C | less -R'

# Environment Variables
export GOPATH="$HOME/go"
export PATH="$PATH:$HOME/bin:/usr/local/bin:/usr/bin:/sbin:/opt/local/bin/\
:$HOME/.pyenv/bin\
:$HOME/.poetry/bin\
:$GOPATH/bin"

# Use GNU core utils
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

# Google Cloud SDK
[[ -f '/usr/local/Caskroom/google-cloud-sdk/latest/google-cloud-sdk/path.zsh.inc' ]] && source "/usr/local/Caskroom/google-cloud-sdk/latest/google-cloud-sdk/path.zsh.inc"
[[ -f '/usr/local/Caskroom/google-cloud-sdk/latest/google-cloud-sdk/completion.zsh.inc' ]] &&
  source "/usr/local/Caskroom/google-cloud-sdk/latest/google-cloud-sdk/completion.zsh.inc"

function current_gcp_project() {
  if [[ -n $CLOUDSDK_ACTIVE_CONFIG_NAME ]]; then
    echo ${CLOUDSDK_ACTIVE_CONFIG_NAME}
  fi
}

# Less Options
export LESS='-g -i -M -R -W -z-4 -x4'

# JDK
export PATH="/opt/homebrew/opt/openjdk@21/bin:$PATH"
export JAVA_HOME=$(/usr/libexec/java_home -v 21)
export PATH="$JAVA_HOME/bin:$PATH"

# Python
if command -v pyenv >/dev/null; then
  eval "$(pyenv init --path)"
  eval "$(pyenv virtualenv-init -)"
fi

# Go
[[ -s "$HOME/.gvm/scripts/gvm" ]] && source "$HOME/.gvm/scripts/gvm"

# C++
export CPLUS_INCLUDE_PATH="$CPLUS_INCLUDE_PATH:$HOME/.csrc:/usr/local/Cellar/boost/1.70.0/include"
export LDFLAGS="-L/usr/local/opt/openblas/lib"
export CPPFLAGS="-I/usr/local/opt/openblas/include"

# Docker
export DOCKER_BUILDKIT=1
export COMPOSE_DOCKER_CLI_BUILD=1

# Google Cloud SDK
export CLOUDSDK_PYTHON_SITEPACKAGES=1
export USE_GKE_GCLOUD_AUTH_PLUGIN=True

# Oh My Zsh
export ZSH="$HOME/.oh-my-zsh"
export ZSH_THEME="candy"
plugins=(
  git brew gem pyenv kubectl gcloud zsh-kubectl-prompt
)
source $ZSH/oh-my-zsh.sh

# Kubectl Completion
if command -v kubectl >/dev/null 2>&1; then
  source <(kubectl completion zsh)
fi

# Language Settings
export LANG=ja_JP.UTF-8
export LC_ALL=ja_JP.UTF-8
setopt print_eight_bit

# Zsh Options
setopt auto_cd
setopt no_beep
setopt nolistbeep
HISTFILE=~/.zsh_history
HISTSIZE=100000
SAVEHIST=100000
setopt share_history
setopt hist_ignore_dups
setopt hist_ignore_all_dups
setopt hist_ignore_space
setopt hist_reduce_blanks

# Editor
export EDITOR="vim"

# Direnv
if command -v direnv >/dev/null 2>&1; then
  eval "$(direnv hook zsh)"
fi

# Completions
fpath=($ZSH/custom/completions $fpath)
autoload -U compinit && compinit

# Functions
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

# Prompt
PROMPT='%{$fg_bold[green]%}%n@%m %{$fg[blue]%}%D{[%X]} %{$reset_color%}%{$fg[white]%}[%~]%{$reset_color%}
$(git_prompt_info) %{$fg[yellow]%}($ZSH_KUBECTL_PROMPT)%{$reset_color%}
%{$fg[blue]%}->%{$fg_bold[blue]%} %#%{$reset_color%} '

function git-delete-merged-branch() {
  local target_branch=${1:-main}
  local exclude_branches='main|master|develop'
  local branches_to_delete=()
  
  git checkout -q "$target_branch" || return 1

  while read -r branch; do
    merge_base=$(git merge-base "$target_branch" "$branch")
    if [[ $(git cherry "$target_branch" $(git commit-tree $(git rev-parse "$branch^{tree}") -p "$merge_base" -m _)) == "-"* ]]; then
      branches_to_delete+=("$branch")
    fi
  done < <(git for-each-ref refs/heads/ '--format=%(refname:short)' | grep -Ev "$exclude_branches")

  if [ ${#branches_to_delete[@]} -eq 0 ]; then
    echo "No merged branches found to delete."
    return 0
  fi

  echo "The following branches will be deleted:"
  printf '%s\n' "${branches_to_delete[@]}"

  echo -n "Do you want to delete these branches? [Y/n] "
  read answer
  case $answer in
    [Yy]* ) 
      for branch in "${branches_to_delete[@]}"; do
        git branch -D "$branch"
        echo "Deleted branch: $branch"
      done
      ;;
    * ) 
      echo "Operation cancelled. No branches were deleted."
      ;;
  esac
}

