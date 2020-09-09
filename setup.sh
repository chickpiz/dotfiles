#!/bin/bash

DEFAULT=$PWD/default
OPTIONAL=$PWD/optional

# CHECK PACKAGE
function pkg_install {
    for name in $1
    do
        if [[ $name != "\\" ]]
        then
            if [[ $(dpkg -s ${name} | grep Status) == *"installed" ]]
            then 
                echo "[-] $1 is already installed"
            else
                sudo apt-get install -y $1
            fi
        fi
    done
}

# ASK AND SETUP
function ask_setup {
    echo "[*] install ${1}? [y/n]"
    read -r answer

    if [ "$answer" == "y" ]
    then
        ${1}_setup
    fi
}

#################### SETTING UP DEFAULT PACKAGES #################### 
#   INCLUDED PACKAGES:                                              #
#       zsh emacs tmux vim git                                      #
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

    sudo add-apt-repository ppa:kelleyk/emacs
    sudo apt-get update
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

function i3_setup {
    echo "[*] i3_setup"

    pkg_install "i3"
    pkg_install "i3blocks"
    pkg_install "rofi"
    pkg_install "feh"

    mkdir -p $HOME/.config

    ln -s $DEFULAT/i3/i3 $HOME/.config/i3
    ln -s $DEFAULT/i3/i3blocks $HOME/.config/i3blocks
}

function vim_setup {
    pkg_install "vim"

    ln -s $DEFAULT/vim/vimrc $HOME/.vimrc
}

function git_setup {
    echo "[*] git_setup"

    pkg_inistall "git"

    ln -s $DEFAULT/git/.gitconfig $HOME/.gitconfig
    echo "[-] git config --global user.name: "
    read -r username
    git config --global user.name $username

    echo "[-] git config --global user.email: "
    read -r useremail
    git config --global user.email $useremail

    cp $DEFAULT/git/gitmessage.txt $HOME/.gitmessage.txt
}

#################### SETTING UP OPTIONAL PACKAGES ################### 
#   INCLUDED PACKAGES:                                              #
#       ranger pyenv                                                #
#####################################################################

function ranger_setup {
    echo "[*] ranger_setup"

    pkg_install "ranger"
}

function pyenv_setup {
    echo "[*] pyenv_setup"
    pkg_install "make build-essential libssl-dev zlib1g-dev libbz2-dev \
                libreadline-dev libsqlite3-dev wget curl llvm libncurses5-dev libncursesw5-dev \
                xz-utils tk-dev libffi-dev liblzma-dev python-openssl git libedit-dev python"

    git clone https://github.com/pyenv/pyenv.git $HOME/.pyenv
    git clone git://github.com/pyenv/pyenv-update.git ~/.pyenv/plugins/pyenv-update

    echo 'export PYENV_ROOT="$HOME/.pyenv"' >> $HOME/.zshrc
    echo 'export PATH="$PYENV_ROOT/bin:$PATH"' >> $HOME/.zshrc
    echo -e 'if command -v pyenv 1>/dev/null 2>&1; then\n  eval "$(pyenv init -)"\nfi' >> $HOME/.zshrc

    pyenv update
    pyenv install --list
    echo "[-] python version to install: "
    read -r version

    pyenv install $version
}

#####################################################################

function default_setup {
    cp $DEFAULT/etc/envvars $HOME/.envvars

    zsh_setup
    emacs_setup
    tmux_setup
    i3_setup
    vim_setup
    git_setup
}

function optional_setup {
    echo "[*] optional setup"

    ask_setup ranger
    ask_setup pyenv

}

# MAIN
if [[ ${1} == "" ]]
then
    default_setup
    optional_setup
    zsh
else
    ${1}_setup
fi
