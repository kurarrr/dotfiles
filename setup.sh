#!/bin/bash

set -e
OS="$(uname -s)"
DOT_DIRECTORY="${HOME}/dotfiles"
DOT_TARBALL="https://github.com/kurarrr/dotfiles/tarball/master"
REMOTE_URL="git@github.com:kurarrr/dotfiles.git"

has() {
  type "$1" > /dev/null 2>&1
}

usage() {
  name=`basename $0`
  cat <<EOF
Usage:
  $name [arguments] [command]
Commands:
  link_files
  deploy
  init
  vscode_settings
Arguments:
  -f $(tput setaf 1)** warning **$(tput sgr0) Overwrite dotfiles.
  -h Print help (this message)
EOF
  exit 1
}

while getopts :f:h opt; do
  case ${opt} in
    f)
      OVERWRITE=true
      ;;
    h)
      usage
      ;;
  esac
done
shift $((OPTIND - 1))

# If missing, download and extract the dotfiles repository
if [ ! -d ${DOT_DIRECTORY} ]; then
  echo "Downloading dotfiles..."
  mkdir ${DOT_DIRECTORY}

  if has "git"; then
    git clone --recursive "${REMOTE_URL}" "${DOT_DIRECTORY}"
  elif has "curl"; then
    curl -fsSLo ${HOME}/dotfiles.tar.gz ${DOT_TARBALL}
    tar -zxf ${HOME}/dotfiles.tar.gz --strip-components 1 -C ${DOT_DIRECTORY}
    rm -f ${HOME}/dotfiles.tar.gz
  else
      die "git or curl required"
  fi
  echo $(tput setaf 2)Download dotfiles complete!. ✔︎$(tput sgr0)
fi

cd ${DOT_DIRECTORY}

mac_configure(){
  source ./lib/configure
}

link_files() {
  # add symbolic link
  for f in .??*
  do
    # Force remove the vim directory if it's already there
    [ -n "${OVERWRITE}" -a -e ${HOME}/${f} ] && rm -f ${HOME}/${f}
    if [ ! -e ${HOME}/${f} ]; then
      # If you have ignore files, add file/directory name here
      [[ ${f} = ".git" ]] && continue
      [[ ${f} = ".gitignore" ]] && continue
      ln -snfv ${DOT_DIRECTORY}/${f} ${HOME}/${f}
    fi
  done

  echo $(tput setaf 2)Deploy dotfiles complete!. ✔︎$(tput sgr0)
}

initialize() {
  # install homebrew
  if ! command -v brew > /dev/null 2>&1; then
      # Install homebrew: https://brew.sh/
      /usr/bin/ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)"
      echo
  fi
  echo "$(tput setaf 2)Install homebrew complete!. ✔︎$(tput sgr0)"
  brew bundle
  ;;
  echo "$(tput setaf 2)Initialize complete!. ✔︎$(tput sgr0)"
}

vscode_settings() {
  # vscode setting
  ln -snfv ${DOT_DIRECTORY}/vscode/settings.json ${HOME}/Library/Application\ Support/Code/User/settings.json
  ln -snfv ${DOT_DIRECTORY}/vscode/keybindings.json ${HOME}/Library/Application\ Support/Code/User/keybindings.json
  ln -snfv ${DOT_DIRECTORY}/vscode/snippets ${HOME}/Library/Application\ Support/Code/User/snippets
}

app_settings() {
  # use zsh as default
  # after installing zsh
  sudo sh -c "echo `which zsh` >> /etc/shells"
  chsh -s '`which zsh`'

  # Install oh-my-zsh
  sh -c "$(wget -O- https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"

  # vscode
  vscode_settings
  
  # gcc
  ln -s /usr/local/bin/gcc-9 /usr/local/bin/gcc
  ln -s /usr/local/bin/g++-9 /usr/local/bin/g++
}

command=$1
[ $# -gt 0 ] && shift

case $command in
  link_files)
    link_files
    ;;
  deploy)
    link_files
    mac_configure
    app_settings
    ;;
  vscode_settings)
    vscode_settings
    ;;
  init*)
    initialize
    ;;
  *)
    usage
    ;;
esac

exit 0
