# mise
eval "$(mise activate zsh)"
export CLOUDSDK_PYTHON="$(mise which python3)"

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

source "$HOME/.zsh/aliases.zsh"

source "$HOME/.zsh/zinit.zsh"

# --- Tool hooks ---
eval "$(atuin init zsh)"
eval "$(zoxide init zsh)"

if command -v direnv >/dev/null 2>&1; then
  eval "$(direnv hook zsh)"
fi

source "$HOME/.zsh/keybinds.zsh"
source "$HOME/.zsh/functions.zsh"

# --- Prompt ---
eval "$(starship init zsh)"
