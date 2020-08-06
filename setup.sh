#!/bin/bash

DEFAULT=$PWD/default
OPTIONAL=$PWD/optional

# CHECK PACKAGE
function pkg_install {
    if command -v $1 
    then 
        echo "[-] $1 is already installed"
    else
        sudo apt-get install -y $1
    fi
}

#################### SETTING UP DEFAULT PACKAGES #################### 
#   INCLUDED PACKAGES:                                              #
#       zsh emacs tmux                                              #
##################################################################### 

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
    ln -s $DEFAULT/emacs/doom.d $HOME/.doom.d
    $HOME/.emacs.d/bin/doom sync

    # INSTALL BEAR (SUPPORT FOR LSP)
    pkg_install "bear"

    # INSTALL CCLS (SUPPORT FOR LSP)
    if lsb_release -a | grep -q '20.04'
    then
	pkg_install "ccls"
    else
	if command -v "ccls" 
	then
	    echo "[-] ccls is already installed"
	    CCLS_PATH=$(which ccls)
	else
	    pushd $HOME/.emacs.d
	    git clone --depth=1 --recursive https://github.com/MaskRay/ccls -o ccls
	    popd

	    pushd $HOME/.emacs.d/ccls
	    wget -c http://releases.llvm.org/8.0.0/clang+llvm-8.0.0-x86_64-linux-gnu-ubuntu-18.04.tar.xz
	    tar xf clang+llvm-8.0.0-x86_64-linux-gnu-ubuntu-18.04.tar.xz
	    cmake -H. -BRelease -DCMAKE_BUILD_TYPE=Release -DCMAKE_PREFIX_PATH=$PWD/clang+llvm-8.0.0-x86_64-linux-gnu-ubuntu-18.04
	    cmake --build Release
	    rm clang+llvm-8.0.0-x86_64-linux-gnu-ubuntu-18.04.tar.xz
	    popd 

	    CCLS_PATH=$HOME/.emacs.d/ccls/Release
	    echo "PATH=$PATH:${CCLS_PATH}" >> $HOME/.envvars
	fi
    fi

    # # INSTALL CMAKE 3.18 (SUPPORT FOR VTERM)
    # if cmake --version | grep -q 3.18
    # then
    # else
    #     pushd $HOME/.emacs.d
    #     wget https://github.com/Kitware/CMake/releases/download/v3.18.0/cmake-3.18.0.tar.gz
    #     tar xvf cmake-3.18.0.tar.gz
    #     popd 

    #     pushd $HOME/emacs.d/cmake-3.18.0
    #     make
    #     popd
    # fi

}

function tmux_setup {
    echo "[*] tmux_setup"

    pkg_install "tmux"
    ln -s $DEFAULT/tmux/tmux.conf $HOME/.tmux.conf
}

#################### SETTING UP OPTIONAL PACKAGES ################### 
#   INCLUDED PACKAGES:                                              #
#       vifm                                                        #
#####################################################################

function vifm_setup {
    echo "[*] vifm_setup"

    pkg_install "vifm"
    rm -rf ~/.vifm
    ln -s $OPTIONAL/vifm $HOME/.vifm
}

#####################################################################

function default_setup {
    cp $DEFAULT/etc/envvars $HOME/.envvars

    zsh_setup
    emacs_setup
    tmux_setup
}

function optional_setup {
    echo "[*] optional setup"

    echo "[*] install vifm? [y/n]"
    read -r vifm

    if [ "$vifm" == "y" ]
    then
        vifm_setup
    fi

    echo vifm is $vifm
}

# MAIN

default_setup
optional_setup
zsh
