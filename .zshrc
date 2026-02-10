# Shared shell config (aliases, PATH, env, common functions)
[ -f "$HOME/.shell_common.sh" ] && source "$HOME/.shell_common.sh"

# nodenv
if command -v nodenv >/dev/null 2>&1; then
  eval "$(nodenv init -)"
fi

# Oh My Zsh
export ZSH="$HOME/.oh-my-zsh"
export ZSH_THEME="candy"
# Build plugin list and only add zsh-kubectl-prompt when installed.
plugins=(git pyenv kubectl gcloud)
if [ -d "${ZSH_CUSTOM:-$ZSH/custom}/plugins/zsh-kubectl-prompt" ]; then
  plugins+=(zsh-kubectl-prompt)
fi
source $ZSH/oh-my-zsh.sh

# Kubectl Completion
if command -v kubectl >/dev/null 2>&1; then
  source <(kubectl completion zsh)
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

# Completions
fpath=($ZSH/custom/completions $fpath)
autoload -U compinit && compinit

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

# Prompt
PROMPT='%{$fg_bold[green]%}%n@%m %{$fg[blue]%}%D{[%X]} %{$reset_color%}%{$fg[white]%}[%~]%{$reset_color%}
$(git_prompt_info) %{$fg[yellow]%}($ZSH_KUBECTL_PROMPT)%{$reset_color%}
%{$fg[blue]%}->%{$fg_bold[blue]%} %#%{$reset_color%} '
