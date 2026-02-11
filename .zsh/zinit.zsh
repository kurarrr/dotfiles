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
