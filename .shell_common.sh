# Shared shell configuration for both zsh and bash.

# Prevent double-loading when both .zprofile and .zshrc source this file.
if [ -n "${SHELL_COMMON_LOADED:-}" ]; then
  return
fi
SHELL_COMMON_LOADED=1

# --- Aliases ---
alias dcp="docker compose"
alias zshconf="vim $HOME/.zshrc"
alias zshrel="source $HOME/.zshrc"
alias k="kubectl"
alias kg="kubectl get"
alias kd="kubectl describe"
alias ktx="kubectx"
alias gcurl='curl --header "Authorization: Bearer $(gcloud auth print-access-token)"'
alias jqless='jq "." -C | less -R'

# --- Paths & Environment ---
export NODENV_ROOT="${NODENV_ROOT:-$HOME/.nodenv}"
PATH="$NODENV_ROOT/bin:$PATH"

export GOPATH="$HOME/go"
export PATH="$PATH:$HOME/bin:/usr/local/bin:/usr/bin:/sbin:/opt/local/bin:$HOME/.pyenv/bin:$HOME/.poetry/bin:$GOPATH/bin:/opt/homebrew/share/google-cloud-sdk/bin"

# Prefer GNU coreutils when available.
for _p in \
  /usr/local/opt/coreutils/libexec/gnubin \
  /usr/local/opt/gnu-sed/libexec/gnubin \
  /usr/local/opt/gawk/libexec/gnubin \
  /usr/local/opt/findutils/libexec/gnubin \
  /usr/local/opt/grep/libexec/gnubin
do
  [ -d "$_p" ] && PATH="$_p:$PATH"
done
for _m in \
  /usr/local/opt/coreutils/libexec/gnuman \
  /usr/local/opt/gnu-sed/libexec/gnuman \
  /usr/local/opt/gawk/libexec/gnuman \
  /usr/local/opt/findutils/libexec/gnuman \
  /usr/local/opt/grep/libexec/gnuman
do
  [ -d "$_m" ] && MANPATH="$_m:${MANPATH:-/usr/share/man}"
done
export PATH MANPATH

# Less
export LESS='-g -i -M -R -W -z-4 -x4'

# JDK
if command -v /usr/libexec/java_home >/dev/null 2>&1; then
  JAVA_HOME=$(/usr/libexec/java_home -v 21 2>/dev/null) && export JAVA_HOME
  export PATH="$JAVA_HOME/bin:$PATH"
fi
export PATH="/opt/homebrew/opt/openjdk@21/bin:$PATH"

# Python (pyenv/virtualenv)
if command -v pyenv >/dev/null 2>&1; then
  eval "$(pyenv init --path)"
  eval "$(pyenv virtualenv-init -)"
fi

# Go (gvm)
[ -s "$HOME/.gvm/scripts/gvm" ] && source "$HOME/.gvm/scripts/gvm"

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

if [ -n "$ZSH_VERSION" ]; then
  [ -f '/usr/local/Caskroom/google-cloud-sdk/latest/google-cloud-sdk/path.zsh.inc' ] && source "/usr/local/Caskroom/google-cloud-sdk/latest/google-cloud-sdk/path.zsh.inc"
  [ -f '/usr/local/Caskroom/google-cloud-sdk/latest/google-cloud-sdk/completion.zsh.inc' ] && source "/usr/local/Caskroom/google-cloud-sdk/latest/google-cloud-sdk/completion.zsh.inc"
elif [ -n "$BASH_VERSION" ]; then
  [ -f '/usr/local/Caskroom/google-cloud-sdk/latest/google-cloud-sdk/path.bash.inc' ] && source "/usr/local/Caskroom/google-cloud-sdk/latest/google-cloud-sdk/path.bash.inc"
  [ -f '/usr/local/Caskroom/google-cloud-sdk/latest/google-cloud-sdk/completion.bash.inc' ] && source "/usr/local/Caskroom/google-cloud-sdk/latest/google-cloud-sdk/completion.bash.inc"
fi

# Direnv
if command -v direnv >/dev/null 2>&1; then
  if [ -n "$ZSH_VERSION" ]; then
    eval "$(direnv hook zsh)"
  elif [ -n "$BASH_VERSION" ]; then
    eval "$(direnv hook bash)"
  fi
fi

# fzf
if [ -n "$ZSH_VERSION" ] && [ -f "$HOME/.fzf.zsh" ]; then
  source "$HOME/.fzf.zsh"
elif [ -n "$BASH_VERSION" ] && [ -f "$HOME/.fzf.bash" ]; then
  source "$HOME/.fzf.bash"
fi

# Language
export LANG=ja_JP.UTF-8
export LC_ALL=ja_JP.UTF-8

# Editor
export EDITOR="vim"

# Git
export GIT_COMPLETION_CHECKOUT_NO_GUESS=1

# --- Functions ---
function current_gcp_project() {
  if [ -n "${CLOUDSDK_ACTIVE_CONFIG_NAME:-}" ]; then
    echo "${CLOUDSDK_ACTIVE_CONFIG_NAME}"
  fi
}

gcsavro() {
  for f in $(gsutil ls "$1"); do
    gsutil cat "$f" | avro-tools tojson - | jq
  done
}

function ghql() {
  local src
  src=$(ghq list | fzf --preview "/bin/ls -laTp $(ghq root)/{} | tail -n+4 | awk '{print $9\"/\"$6\"/\"$7 \" \" $10}'")
  [ -n "$src" ] && cd "$(ghq root)/$src"
}

function gitc() {
  local branches branch
  branches=$(git branch | sed -e 's/^\* //g' | sed -e 's/^  //g' | cut -d " " -f 1) &&
    branch=$(echo "$branches" | fzf --preview "git log --graph --full-history --color --first-parent {}") &&
    git checkout "$branch"
}

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

  printf "Do you want to delete these branches? [Y/n] "
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
