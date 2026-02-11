# Homebrew completions
fpath=( /opt/homebrew/share/zsh/site-functions $fpath )

# PATH configuration
path=(
  /opt/homebrew/bin(N-/)
  /opt/homebrew/sbin(N-/)
  /usr/local/bin(N-/)
  /usr/local/sbin(N-/)
  /usr/bin(N-/)
  /bin(N-/)
  /usr/sbin(N-/)
  /sbin(N-/)
  $HOME/bin(N-/)
  $HOME/.poetry/bin(N-/)
  /opt/homebrew/share/google-cloud-sdk/bin(N-/)
)

# GNU coreutils (prepend to PATH)
for _p in /opt/homebrew/opt/{coreutils,gnu-sed,gawk,findutils,grep}/libexec/gnubin(N-/); do
  path=( $_p $path )
done

# MANPATH configuration
for _m in /opt/homebrew/opt/{coreutils,gnu-sed,gawk,findutils,grep}/libexec/gnuman(N-/); do
  MANPATH="$_m:${MANPATH:-/usr/share/man}"
done
export MANPATH

# Google Cloud SDK
export CLOUDSDK_PYTHON_SITEPACKAGES=1
export USE_GKE_GCLOUD_AUTH_PLUGIN=True

# Docker
export DOCKER_BUILDKIT=1
export COMPOSE_DOCKER_CLI_BUILD=1

# General
export LESS='-g -i -M -R -W -z-4 -x4'
export EDITOR="vim"
export LANG=ja_JP.UTF-8
export LC_ALL=ja_JP.UTF-8
export GIT_COMPLETION_CHECKOUT_NO_GUESS=1

# bat
export BAT_THEME="TwoDark"
