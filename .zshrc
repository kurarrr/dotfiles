# Shared shell config (aliases, PATH, env, common functions)
[ -f "$HOME/.shell_common.sh" ] && source "$HOME/.shell_common.sh"

# nodenv
if command -v nodenv >/dev/null 2>&1; then
  eval "$(nodenv init -)"
fi

# Language Settings
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

# z
zinit light rupa/z

# fzf
zinit light junegunn/fzf

autoload -U compinit && compinit

eval "$(atuin init zsh)"

# Functions
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

zinit from"gh-r" as"program" for starship/starship
eval "$(starship init zsh)"
