#!/usr/bin/env bash

set -Eeuo pipefail
trap cleanup SIGINT SIGTERM ERR EXIT

# If you need to cd to the script directory:
script_dir=$(cd "$(dirname "${BASH_SOURCE[0]}")" &>/dev/null && pwd -P)

usage() {
    cat <<EOF
Usage: $(basename "${BASH_SOURCE[0]}") [-h] [-v] [-f] -p param_value arg1 [arg2...]

Script description here.

Available options:

-h, --help      Print this help and exit
-v, --verbose   Print script debug info
-f, --flag      Some flag description
-p, --param     Some param description
EOF
    exit
}

cleanup() {
    trap - SIGINT SIGTERM ERR EXIT
    # script cleanup here
}

setup_colors() {
    if [[ -t 2 ]] && [[ -z "${NO_COLOR-}" ]] && [[ "${TERM-}" != "dumb" ]]; then
        NOFORMAT='\033[0m' RED='\033[0;31m' GREEN='\033[0;32m' ORANGE='\033[0;33m' BLUE='\033[0;34m' PURPLE='\033[0;35m' CYAN='\033[0;36m' YELLOW='\033[1;33m'
    else
        NOFORMAT='' RED='' GREEN='' ORANGE='' BLUE='' PURPLE='' CYAN='' YELLOW=''
    fi
}

msg() {
    echo >&2 -e "${1-}"
}

die() {
    local msg=$1
    local code=${2-1} # default exit status 1
    msg "$msg"
    exit "$code"
}

parse_params() {
    # default values of variables set from params
    # flag=0
    # param=''

    while :; do
        case "${1-}" in
            -h | --help) usage ;;
            -v | --verbose) set -x ;;
            # --no-color) NO_COLOR=1 ;;
            # -f | --flag) flag=1 ;; # example flag
            # -p | --param) # example named parameter
            #     param="${2-}"
            #     shift
            #     ;;
            -?*) die "Unknown option: $1" ;;
            *) break ;;
        esac
        shift
    done

    args=("$@")

    # check required params and arguments
    # [[ -z "${param-}" ]] && die "Missing required parameter: param"
    # [[ ${#args[@]} -eq 0 ]] && die "Missing script arguments"

    return 0
}

msg_info() {
    msg "${GREEN}[INFO] ${1}${NOFORMAT}"
}

msg_err() {
    msg "${RED}[ERROR] ${1}${NOFORMAT}"
}

parse_params "$@"
setup_colors

# script logic here

# msg "${RED}Read parameters:${NOFORMAT}"
# msg "- flag: ${flag}"
# msg "- param: ${param}"
# msg "- arguments: ${args[*]-}"

cd ~

SCRIPTDIR="${script_dir}"

if ! command -v yay &> /dev/null
then
    msg_info "Installing yay..."
    sudo pacman -S --needed git
    git clone https://aur.archlinux.org/yay.git
    cd yay
    makepkg -si
    cd ..
    rm -rf yay
fi

if ! [ -f repo_installed ]; then
    msg_info "Installing packages from the arch repos..."
    yay -S --needed - < $SCRIPTDIR/pkglist.txt
    yay -S --needed --asdeps - < $SCRIPTDIR/optdeplist.txt && touch repo_installed
else
    msg_info "Skipping already installed packages from arch repos"
fi

# if [ -f aur_installed ]; then
#     msg_info "Installing packages from the aur..."
#     yay -S --noconfirm --needed $SCRIPTDIR/pkglistaur.txt && touch aur_installed
# else
#     msg_info "Skipping already installed packages from aur"
# fi

if ! [ -f pip_installed ]; then
    msg_info "Installing python packages..."
    sudo pip install -r $SCRIPTDIR/pkglistpip.txt && touch pip_installed
else
    msg_info "Skipping already installed python packages"
fi

if ! [ -d dotfiles ]; then
    msg_info "Installing dotfiles"
    git clone https://github.com/fran-penedo/dotfiles.git dotfiles
    cd dotfiles
    chmod +x makesymlinks.sh
    echo "[include]
    path = ../.gitconfig" >> .git/config
    ./makesymlinks.sh
    cd ..
else
    msg_info "Skipping already installed dotfiles"
fi

if ! [ -d .emacs.d ]; then
    msg_info "Installing spacemacs"
    git clone https://github.com/fran-penedo/spacemacs.git .emacs.d
fi

sudo install -v  $SCRIPTDIR/00-keyboard.conf /etc/X11/xorg.conf.d/

sudo systemctl enable slim.service

sudo install -v $SCRIPTDIR/resume@.service /etc/systemd/system/
sudo systemctl enable resume@fran.service

cd /usr/share/git/credential/gnome-keyring
sudo make
cd
