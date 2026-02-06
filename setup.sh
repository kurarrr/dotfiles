#!/bin/bash

set -e
OS="$(uname -s)"
DOT_DIRECTORY="${HOME}/src/github.com/kurarrr/dotfiles"
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

  if has "curl"; then
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
  # Files to force overwrite (managed by dotfiles)
  local force_overwrite_files=(
    ".bashrc"
    ".gitconfig"
    ".gitignore_global"
    ".shell_common.sh"
    ".tmux.conf"
    ".vimrc"
    ".zprofile"
    ".zshrc"
  )
  
  # add symbolic link
  for f in .??*
  do
    # If you have ignore files, add file/directory name here
    [[ ${f} = ".git" ]] && continue
    [[ ${f} = ".gitignore" ]] && continue
    
    # Check if this file should be force overwritten
    local should_force_overwrite=false
    for managed_file in "${force_overwrite_files[@]}"; do
      if [[ ${f} = ${managed_file} ]]; then
        should_force_overwrite=true
        break
      fi
    done
    
    # Force remove if it's a managed file
    if [ ${should_force_overwrite} = true ] && [ -e ${HOME}/${f} ]; then
      rm -rf ${HOME}/${f}
      ln -snfv ${DOT_DIRECTORY}/${f} ${HOME}/${f}
    elif [ ! -e ${HOME}/${f} ]; then
      # Create link only if file doesn't exist
      ln -snfv ${DOT_DIRECTORY}/${f} ${HOME}/${f}
    fi
  done

  echo $(tput setaf 2)Deploy dotfiles complete!. ✔︎$(tput sgr0)
}

initialize() {
  # install homebrew
  if ! command -v brew > /dev/null 2>&1; then
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
  fi
  echo "$(tput setaf 2)Install homebrew complete!. ✔︎$(tput sgr0)"
  brew bundle
  echo "$(tput setaf 2)Initialize complete!. ✔︎$(tput sgr0)"
}

app_settings() {
  # use zsh as default
  # after installing zsh
  sudo sh -c "echo `which zsh` >> /etc/shells"
  chsh -s '`which zsh`'

  # Install oh-my-zsh
  sh -c "$(wget -O- https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"

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
  init*)
    initialize
    ;;
  *)
    usage
    ;;
esac

exit 0
