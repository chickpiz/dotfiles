#!/bin/bash

DEFAULT=$PWD/default
OPTIONAL=$PWD/optional

# HELP
function help {
    grep "^function.*setup" $0 | awk '{print $2}' | awk -F_ '{print $1}'
}

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

# ASK AND INSTALL
function ask_install {
    echo "[*] install ${1}? [y/n]"
    read -r answer

    if [ "$answer" == "y" ]
    then
        ${1}_setup
    fi
}

#################### SETTING UP MINIMIZL PACKAGES ###################
#   INCLUDED PACKAGES:                                              #
#       htop python                                                 #
#####################################################################

function minimal_setup {
    echo "[*] minimal_setup"

    echo "[*] htop_setup"
    pkg_install "htop"

    echo "[*] python_setup"
    pkg_install "python"
    pkg_install "python3" 

    echo "[*] arandr_setup"
    pkg_install "arandr"
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

    git clone https://github.com/zsh-users/zsh-autosuggestions.git ${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/plugins/zsh-autosuggestions

    rm $HOME/.zshrc
    cp $DEFAULT/zsh/zshrc $HOME/.zshrc
    cp $DEFAULT/zsh/p10k.zsh $HOME/.p10k.zsh

    # Need to make not get password
    echo "sudo chsh -s $(which zsh) $USER"
    sudo chsh -s $(which zsh) $USER
}

function emacs_setup {
    echo "[*] emacs_setup"

    sudo add-apt-repository ppa:kelleyk/emacs
    sudo apt-get update
    pkg_install "emacs27"

    git clone --depth 1 https://github.com/hlissner/doom-emacs $HOME/.emacs.d

    # INSTALL BEAR (SUPPORT FOR C/C++ LSP)
    pkg_install "bear"

    # INSTALL CCLS (SUPPORT FOR C/C++ LSP)
    pkg_install "ccls clangd-9"

    # INSTALL PYLS (SUPPORT FOR PYTHON LSP)
    pkg_install "python-pip python3-pip"
    pip install python-lsp-server
    pip3 install python-lsp-server

    # INSTALL CMAKE 3.18 (SUPPORT FOR VTERM)
    if cmake --version | grep -q 3.18
    then
        echo "[-] cmake already 3.18"
    else
        pushd $HOME/.emacs.d
        wget https://github.com/Kitware/CMake/releases/download/v3.18.0/cmake-3.18.0.tar.gz
        tar xvf cmake-3.18.0.tar.gz
        popd 

        pushd $HOME/.emacs.d/cmake-3.18.0
        ./configure
        make
        popd

        pkg_install "libtool libtool-bin"
    fi

    # INSTALL Fira code font
    pkg_install "fonts-firacode"

    $HOME/.emacs.d/bin/doom install

    rm -r $HOME/.doom.d
    cp -r $DEFAULT/emacs/doom.d $HOME/.doom.d
    $HOME/.emacs.d/bin/doom sync
}

function tmux_setup {
    echo "[*] tmux_setup"

    pkg_install "tmux xclip"
    cp $DEFAULT/tmux/tmux.conf $HOME/.tmux.conf
}

function i3_setup {
    echo "[*] i3_setup"

    mkdir -p $HOME/.config/i3

    pkg_install "i3"
    pkg_install "i3lock"
    pkg_install "i3blocks"
    pkg_install "rofi"
    pkg_install "feh"

    # INSTALL Polybar for Ubuntu 20.04
    pkg_install "build-essential git cmake cmake-data pkg-config python3-sphinx \
                 python3-packaging libuv1-dev libcairo2-dev libxcb1-dev libxcb-util0-dev \
                 libxcb-randr0-dev libxcb-composite0-dev python3-xcbgen xcb-proto \ 
                 libxcb-image0-dev libxcb-ewmh-dev libxcb-icccm4-dev"

    pkg_install "libxcb-xkb-dev libxcb-xrm-dev libxcb-cursor-dev libasound2-dev \ 
                 libpulse-dev i3-wm libjsoncpp-dev libmpdclient-dev libcurl4-openssl-dev \
                 libnl-genl-3-dev"

    git clone --depth 1 -b 3.6.3 --recursive https://github.com/polybar/polybar $HOME/.config/i3/polybar
    mkdir $HOME/.config/i3/polybar/build
    pushd $HOME/.config/i3/polybar/build
    cmake ..
    make -j4
    sudo make install
    popd

    pkg_install "net-tools"

    cp $DEFULAT/i3/config $HOME/.config/i3/config
    cp $DEFAULT/i3/slow_mouse.sh $HOME/.config/i3/slow_mouse.sh
    cp $DEFAULT/i3/polybar/config $HOME/.config/i3/polybar/config
    cp $DEFAULT/i3/polybar/launch.sh $HOME/.config/i3/polybar/launch.sh

    mkdir -p $HOME/.screenlayout
    cp $DEFAULT/i3/dual-monitor.sh $HOME/.screenlayout/dual-monitor.sh

    git clone https://github.com/shikherverma/i3lock-multimonitor $HOME/.config/i3/i3lock-multimonitor
    sudo chmod +x $HOME/.config/i3/i3lock-multimonitor/lock
}

function vim_setup {
    pkg_install "vim"

    cp $DEFAULT/vim/vimrc $HOME/.vimrc
}

function git_setup {
    echo "[*] git_setup"

    pkg_install "git"

    cp $DEFAULT/git/.gitconfig $HOME/.gitconfig
    echo "[-] git config --global user.name: "
    read -r username
    git config --global user.name $username

    echo "[-] git config --global user.email: "
    read -r useremail
    git config --global user.email $useremail

    echo "[-] git config --global editor"
    git config --global core.editor vim

    cp $DEFAULT/git/gitmessage.txt $HOME/.gitmessage.txt
}

#################### SETTING UP OPTIONAL PACKAGES ################### 
#   INCLUDED PACKAGES:                                              #
#       ranger pyenv rclone                                         #
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

    PYENV_ROOT=$HOME/.pyenv
    echo 'PYENV_ROOT="$HOME/.pyenv"' >> $HOME/.envvars
    # echo 'export PYENV_ROOT="$HOME/.pyenv"' >> $HOME/.zshrc
    PATH=$PYENV_ROOT/bin:$PATH
    # echo 'export PATH="$PYENV_ROOT/bin:$PATH"' >> $HOME/.zshrc
    echo -e 'if command -v pyenv 1>/dev/null 2>&1; then\n  eval "$(pyenv init --path)"\n  eval "$(pyenv init - @> /dev/null)"\nfi' >> $HOME/.zshrc

    $PYENV_ROOT/bin/pyenv update
    $PYENV_ROOT/bin/pyenv install --list
    echo "[-] python version to install: "
    read -r version

    $PYENV_ROOT/bin/pyenv install $version
}

function rclone_setup {
    echo "[*] rclone_setup"
    pkg_install "rclone"

    echo "[-] configure rclone, must set name: google-drive"
    rclone config

    mkdir $HOME/google-drive
    sudo ln -s $OPTIONAL/rclone/gsync /usr/bin/gsync

    echo "[-] register auto-backup"
    (crontab -l 2>/dev/null; echo "0 0 * * * gsync $HOME/google-drive > /dev/null 2>&1") | crontab -e 
}

#####################################################################

function default_setup {
    echo "[*] default setup"

    git_setup
    zsh_setup
    emacs_setup
    tmux_setup
    i3_setup
    vim_setup
}

function optional_setup {
    echo "[*] optional setup"

    ask_install ranger
    ask_install pyenv
    ask_install rclone
}

# MAIN
if [[ ${1} == "" ]]
then
    cp $DEFAULT/etc/envvars $HOME/.envvars

    PATH=$PATH
    minimal_setup
    default_setup
    optional_setup

    echo "PATH=$PATH" >> $HOME/.envvars
    zsh
elif [[ ${1} == "help" ]]
then
    echo "[*] List of available packages"
    help
else
    ${1}_setup
fi
