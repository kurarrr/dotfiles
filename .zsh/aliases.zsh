alias dcp="docker compose"
alias zshconf="vim $HOME/.zshrc"
alias zshrel="source $HOME/.zshrc"
alias dotlink="$HOME/src/github.com/kurarrr/dotfiles/setup.sh link"
alias k="kubectl"
alias kg="kubectl get"
alias kd="kubectl describe"
alias ktx="kubectx"
alias gcurl='curl --header "Authorization: Bearer $(gcloud auth print-access-token)"'
alias jqless='jq "." -C | less -R'
alias openr="open -R"

# Modern CLI replacements (interactive only - skip for scripts/LLM agents)
if [[ -o interactive ]]; then
  alias cat="bat --paging=never --style=plain"
  alias less="bat --paging=always"
  alias ls="eza --icons --git"
  alias ll="eza --icons --git -l"
  alias la="eza --icons --git -la"
  alias tree="eza --tree --icons"
fi
