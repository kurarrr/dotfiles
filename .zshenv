# PATH configuration
path=(
  /opt/homebrew/bin(N-/)
  /opt/homebrew/sbin(N-/)
  /opt/homebrew/opt/openjdk@21/bin(N-/)
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

# Go
export GOPATH="$HOME/go"
path+=( $GOPATH/bin(N-/) )

# JDK
if command -v /usr/libexec/java_home >/dev/null 2>&1; then
  JAVA_HOME=$(/usr/libexec/java_home -v 21 2>/dev/null) && export JAVA_HOME
  path=( $JAVA_HOME/bin $path )
fi

# GNU coreutils (Intel Mac)
for _p in /usr/local/opt/{coreutils,gnu-sed,gawk,findutils,grep}/libexec/gnubin; do
  [ -d "$_p" ] && path=( $_p $path )
done
for _m in /usr/local/opt/{coreutils,gnu-sed,gawk,findutils,grep}/libexec/gnuman; do
  [ -d "$_m" ] && MANPATH="$_m:${MANPATH:-/usr/share/man}"
done
export MANPATH

# Google Cloud SDK
export CLOUDSDK_PYTHON_SITEPACKAGES=1
export USE_GKE_GCLOUD_AUTH_PLUGIN=True

# C++
export CPLUS_INCLUDE_PATH="$CPLUS_INCLUDE_PATH:$HOME/.csrc:/usr/local/Cellar/boost/1.70.0/include"
export LDFLAGS="-L/usr/local/opt/openblas/lib"
export CPPFLAGS="-I/usr/local/opt/openblas/include"

# Docker
export DOCKER_BUILDKIT=1
export COMPOSE_DOCKER_CLI_BUILD=1

# General
export LESS='-g -i -M -R -W -z-4 -x4'
export EDITOR="vim"
export LANG=ja_JP.UTF-8
export LC_ALL=ja_JP.UTF-8
export GIT_COMPLETION_CHECKOUT_NO_GUESS=1
