export PYENV_ROOT="$HOME/.pyenv"
export PATH="$PYENV_ROOT/bin:$PATH"
eval "$(pyenv init -)"

export NODE_PATH=/usr/local/lib/node_modules

export PATH="/Library/TeX/texbin:$PATH"

export PATH="$HOME/.rbenv/bin:$PATH"
if which rbenv > /dev/null; then eval "$(rbenv init -)"; fi

export PATH=/usr/local/opt/imagemagick@6/bin:$PATH
export LDFLAGS=-L/usr/local/opt/imagemagick@6/lib

export CPPFLAGS=-I/usr/local/opt/imagemagick@6/include
export PKG_CONFIG_PATH=/usr/local/opt/imagemagick@6/lib/pkgconfig
export CPLUS_INCLUDE_PATH=$CPLUS_INCLUDE_PATH:/Users/ryota/.csrc

#if [ -f ~/.bashrc ] ; then
#. ~/.bashrc
#fi

[[ -s "/Users/ryota/.gvm/scripts/gvm" ]] && source "/Users/ryota/.gvm/scripts/gvm"
