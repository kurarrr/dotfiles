# Option+Left/Right: word navigation (prevent entering vi normal mode)
bindkey '\e[1;3D' backward-word   # iTerm2: Option+Left
bindkey '\e[1;3C' forward-word    # iTerm2: Option+Right
bindkey '\eb'     backward-word   # Terminal.app: Option+Left
bindkey '\ef'     forward-word    # Terminal.app: Option+Right

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
