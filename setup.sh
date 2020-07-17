#!/bin/bash

DEFAULT=$PWD/default

# CHECK PACKAGE
function pkg_install {
    if apt-cache policy $1 | grep -q 'Installed: (none)'
    then 
        sudo apt-get install -y $1
        echo "yes"
    else
        echo "[-] $1 is already installed"
    fi
}

# SETTING UP DEFAULT PACKAGES
#   INCLUDED PACKAGES:
#       zsh emacs tmux

function zsh_setup {
    echo "[*] zsh_setup"

    pkg_install "zsh"

    source $DEFAULT/zsh/ohmyzsh.sh --skip-chsh
    git clone --depth=1 https://github.com/romkatv/powerlevel10k.git ${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/themes/powerlevel10k
    pkg_install "autojump"
    git clone https://github.com/zsh-users/zsh-autosuggestions ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-autosuggestions

    rm $HOME/.zshrc
    ln -s $DEFAULT/zsh/zshrc $HOME/.zshrc
    ln -s $DEFAULT/zsh/p10k.zsh $HOME/.p10k.zsh

    # Need to make not get password
    chsh -s $(which zsh)
}

function emacs_setup {
    echo "[*] emacs_setup"

    pkg_install "emacs26"

    git clone --depth 1 https://github.com/hlissner/doom-emacs $HOME/.emacs.d
    $HOME/.emacs.d/bin/doom install

    rm -r $HOME/.doom.d
    ln -s $DEFULAT/emacs/.doom.d $HOME/.doom.d
    $HOME/.emacs.d/doom sync
}

function tmux_setup {
    echo "[*] tmux_setup"

    pkg_install "tmux"
    ln -s $DEFULAT/tmux/tmux.conf $HOME/.tmux.conf
}


main () {
    zsh_setup
    emacs_setup
    tmux_setup

    zsh
}

# SETTING UP OPTIONAL PACKAGES
