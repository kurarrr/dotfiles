# Load shared aliases, PATH, env vars, and common functions.
[ -f "$HOME/.shell_common.sh" ] && source "$HOME/.shell_common.sh"

# Bash completions
if command -v kubectl >/dev/null 2>&1; then
  source <(kubectl completion bash)
fi

if [ -f /opt/homebrew/etc/profile.d/bash_completion.sh ]; then
  . /opt/homebrew/etc/profile.d/bash_completion.sh
elif [ -f /usr/local/etc/bash_completion ]; then
  . /usr/local/etc/bash_completion
fi

# Prompt (keep simple for bash)
PS1='\u@\h [\W]\$ '
