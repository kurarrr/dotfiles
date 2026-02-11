fzf-z-search() {
  local res=$(zoxide query -l | fzf --no-sort)
  if [ -n "$res" ]; then
    BUFFER="cd ${(q)res}"
    zle accept-line
  fi
}

zle -N fzf-z-search
bindkey '^f' fzf-z-search

yy-widget() { yy; zle reset-prompt }
zle -N yy-widget
bindkey '^y' yy-widget
