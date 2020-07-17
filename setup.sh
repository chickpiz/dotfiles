#!/bin/bash

# CHECK PACKAGE
function pkg_install {
    if apt-cache policy $1 | grep -q Installed
    then 
        echo "[-] $1 is already installed"
    else
        sudo apt-get install -y $1
        echo "yes"
    fi
}

# SETTING UP DEFAULT PACKAGES
#   INCLUDED PACKAGES:
#       zsh emacs tmux


function zsh_setup {
    echo "[*] zsh_setup"

    pkg_install "zsh"

    sudo chsh -s $(which zsh)
    echo "Should reboot"
    zsh

    pkg_install "curl"
    sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"

    ln -s rc/zshrc $HOME/.zshrc
}

function emacs_setup {
    echo "[*] emacs_setup"

    pkg_install "emacs"
}

zsh_setup
emacs_setup


# SETTING UP OPTIONAL PACKAGES
