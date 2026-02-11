# mise
eval "$(mise activate zsh)"

# Zsh Options
setopt print_eight_bit
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

# --- zinit ---
source "$HOME/.local/share/zinit/zinit.git/zinit.zsh"
autoload -Uz _zinit
(( ${+_comps} )) && _comps[zinit]=_zinit

# Load a few important annexes, without Turbo
# (this is currently required for annexes)
zinit light-mode for \
    zdharma-continuum/zinit-annex-as-monitor \
    zdharma-continuum/zinit-annex-patch-dl \

# Git (補完 + 情報)
zinit light zsh-users/zsh-completions
zinit light zsh-users/zsh-autosuggestions
zinit light zsh-users/zsh-syntax-highlighting

# kubectl prompt
zinit light superbrothers/zsh-kubectl-prompt

# kubectl 補完（公式）
zinit ice as"completion"
zinit light kubernetes/kubectl

# fzf
zinit light junegunn/fzf

autoload -U compinit && compinit

# --- Tool hooks ---
eval "$(atuin init zsh)"
eval "$(zoxide init zsh)"

if command -v direnv >/dev/null 2>&1; then
  eval "$(direnv hook zsh)"
fi

[ -f "$HOME/.fzf.zsh" ] && source "$HOME/.fzf.zsh"

# --- Functions ---
fzf-z-search() {
  local res=$(zoxide query -l | fzf --no-sort)
  if [ -n "$res" ]; then
    BUFFER="cd ${(q)res}"
    zle accept-line
  fi
}

zle -N fzf-z-search
bindkey '^f' fzf-z-search

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
  src=$(ghq list | fzf --preview "/bin/ls -laTp $(ghq root)/{} | tail -n+4 | awk '{print \$9\"/\"\$6\"/\"\$7 \" \" \$10}'")
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

# --- Prompt ---
eval "$(starship init zsh)"
