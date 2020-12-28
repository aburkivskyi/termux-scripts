#!/data/data/com.termux/files/usr/bin/env bash
##
set -euo pipefail
SAVEIFS="$IFS"
IFS=$'\n\t'
# IFS="$(printf '\n\t')"
##

PROGRAM_NAME='setup-termux'
PROGRAMM_VERSION=0.10

readonly SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
readonly SCRIPT_NAME="$( basename "${BASH_SOURCE[0]}" )"
readonly DIGIT='^[0-9]+$'
readonly PROPS="${HOME}/.termux/termux.properties"

NUL=/dev/null
USHELL="$( basename "${SHELL}" )"
omz_url='https://raw.githubusercontent.com/robbyrussell/oh-my-zsh/master/tools/install.sh'
colors_prop_url='https://cdn.jsdelivr.net/gh/4679/oh-my-termux@master/.termux/colors.properties'
fonts_url='https://cdn.jsdelivr.net/gh/4679/oh-my-termux@master/.termux/font.ttf'
pkgs=(
  'curl'
  'libcurl'
  'git'
  'zsh'
  'termux-exec'
)

checkRoot() {     ## ANTI-ROOT
  if [ "$EUID" -eq 0 ]; then
	  echo -e "\nError: utility $PROGRAM_NAME should not be used as root."
	  exit 201
  fi
}

installPackages() {
  pkg install -y "$pkgs[*]"

}

sleepANDclear() {
  local t
  t="${1:-1}"
  if ! [[ $t =~ $DIGIT ]]; then
    echo -e "Error: \"$t\" - not a digit."
    exit 202
  fi

  sleep "${t}s" && clear
}

setupProperties() {
  if [ -d "$HOME/.termux" ]; then
    mv "$HOME/.termux" "$HOME/.termux.bak"
  fi

  curl -fsLo "${HOME}/.termux/colors.properties" --create-dirs "${colors_prop_url}"
  curl -fsLo "${HOME}/.termux/font.ttf" --create-dirs "${fonts_url}"

  cat <<'EOF' >"$PROPS"
use-black-ui = true
EOF

  sleepANDclear
  termux-reload-settings
}

setupZshell() {
  sh -c "$( curl -fsSL "${omz_url}" )"
  cp "${HOME}/.oh-my-zsh/templates/zshrc.zsh-template" "${HOME}/.zshrc"
  sed -i 's/ZSH_THEME="robbyrussell"/ZSH_THEME="agnoster"/' "${HOME}/.zshrc"
  chsh -s zsh
  termux-reload-settings
  sleepANDclear
  echo "Done! Please restart Termux."
}

main() {
  checkRoot
  pkg update
  pkg upgrade -y
  installPackages
  termux-setup-storage
  sleepANDclear 3
  setupProperties
  [[ $USHELL != "zsh" ]] && \
      setupZshell

  exit 0
}

main "${@}" || exit 200