#!/bin/bash

set -e

DOT_DIRECTORY="${HOME}/src/github.com/kurarrr/dotfiles"
DOT_TARBALL="https://github.com/kurarrr/dotfiles/tarball/master"
REMOTE_URL="git@github.com:kurarrr/dotfiles.git"

usage() {
  local name
  name=$(basename "$0")
  cat <<EOF
Usage:
  $name <command>

Commands:
  install    Full setup for a fresh Mac (xcode-cli, git repo, brew, zinit, deps, links)
  link       Create symlinks only
  configure  Apply macOS system preferences
EOF
  exit 1
}

# ── Step functions (idempotent) ──────────────────────────────────────

install_xcode_cli_tools() {
  if xcode-select -p > /dev/null 2>&1; then
    echo "Xcode CLI tools already installed. ✔︎"
    return
  fi
  echo "Installing Xcode CLI tools..."
  xcode-select --install
  echo "Waiting for Xcode CLI tools installation to finish..."
  until xcode-select -p > /dev/null 2>&1; do
    sleep 5
  done
  echo "Xcode CLI tools installed. ✔︎"
}

setup_git_repo() {
  if [ -d "${DOT_DIRECTORY}/.git" ]; then
    echo "Git repo already exists. ✔︎"
    return
  fi
  echo "Converting tarball directory to git repo..."
  local tmp
  tmp=$(mktemp -d)
  git clone "${REMOTE_URL}" "${tmp}/dotfiles"
  # Move .git into the existing directory
  mv "${tmp}/dotfiles/.git" "${DOT_DIRECTORY}/.git"
  rm -rf "${tmp}"
  # Reset working tree to match HEAD
  cd "${DOT_DIRECTORY}"
  git checkout -- .
  echo "Git repo setup complete. ✔︎"
}

install_homebrew() {
  if command -v brew > /dev/null 2>&1; then
    echo "Homebrew already installed. ✔︎"
    return
  fi
  echo "Installing Homebrew..."
  /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
  # Apple Silicon support
  if [ -x /opt/homebrew/bin/brew ]; then
    eval "$(/opt/homebrew/bin/brew shellenv)"
  fi
  echo "Homebrew installed. ✔︎"
}

install_zinit() {
  if [ -d "${HOME}/.local/share/zinit" ]; then
    echo "zinit already installed. ✔︎"
    return
  fi
  echo "Installing zinit..."
  bash -c "$(curl --fail --show-error --silent --location https://raw.githubusercontent.com/zdharma-continuum/zinit/HEAD/scripts/install.sh)"
  echo "zinit installed. ✔︎"
}

install_brew_deps() {
  echo "Installing Homebrew dependencies..."
  brew bundle --file="${DOT_DIRECTORY}/Brewfile"
  echo "Homebrew dependencies installed. ✔︎"
}

link_files() {
  local force_overwrite_files=(
    ".bashrc"
    ".gitconfig"
    ".gitignore_global"
    ".shell_common.sh"
    ".tmux.conf"
    ".vimrc"
    ".zprofile"
    ".zshrc"
    ".zshenv"
  )

  cd "${DOT_DIRECTORY}"
  for f in .??*; do
    [[ ${f} = ".git" ]] && continue
    [[ ${f} = ".gitignore" ]] && continue

    local should_force=false
    for managed in "${force_overwrite_files[@]}"; do
      if [[ ${f} = "${managed}" ]]; then
        should_force=true
        break
      fi
    done

    if [ "${should_force}" = true ] && [ -e "${HOME}/${f}" ]; then
      rm -rf "${HOME:?}/${f}"
      ln -snfv "${DOT_DIRECTORY}/${f}" "${HOME}/${f}"
    elif [ ! -e "${HOME}/${f}" ]; then
      ln -snfv "${DOT_DIRECTORY}/${f}" "${HOME}/${f}"
    fi
  done

  echo "Symlinks created. ✔︎"
}

link_starship_config() {
  mkdir -p "${HOME}/.config"
  if [ -e "${HOME}/.config/starship.toml" ]; then
    rm -f "${HOME}/.config/starship.toml"
  fi
  ln -snfv "${DOT_DIRECTORY}/.config/starship.toml" "${HOME}/.config/starship.toml"
}

link_git_ignore() {
  mkdir -p "${HOME}/.config/git"
  if [ -e "${HOME}/.config/git/ignore" ]; then
    rm -f "${HOME}/.config/git/ignore"
  fi
  ln -snfv "${DOT_DIRECTORY}/.config/git/ignore" "${HOME}/.config/git/ignore"
}

mac_configure() {
  source "${DOT_DIRECTORY}/lib/configure"
}

# ── If missing, download and extract the dotfiles repository ─────────

if [ ! -d "${DOT_DIRECTORY}" ]; then
  echo "Downloading dotfiles..."
  mkdir -p "${DOT_DIRECTORY}"
  if command -v curl > /dev/null 2>&1; then
    curl -fsSLo "${HOME}/dotfiles.tar.gz" "${DOT_TARBALL}"
    tar -zxf "${HOME}/dotfiles.tar.gz" --strip-components 1 -C "${DOT_DIRECTORY}"
    rm -f "${HOME}/dotfiles.tar.gz"
  else
    echo "curl is required" >&2
    exit 1
  fi
  echo "Download dotfiles complete. ✔︎"
fi

cd "${DOT_DIRECTORY}"

# ── Command dispatch ─────────────────────────────────────────────────

command="${1:-}"
case "${command}" in
  install)
    install_xcode_cli_tools
    setup_git_repo
    install_homebrew
    install_zinit
    install_brew_deps
    link_files
    link_starship_config
    link_git_ignore
    echo "Install complete. ✔︎"
    ;;
  link)
    link_files
    link_starship_config
    link_git_ignore
    ;;
  configure)
    mac_configure
    ;;
  *)
    usage
    ;;
esac

exit 0
