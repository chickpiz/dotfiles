#!/usr/bin/bash

CONFIGS=$PWD/configs

function install {
    for pkg in $1;
    do
        if [ "$(pacsift --exact --name $pkg)" ]; then
            sudo pacman -Sy --needed --noconfirm $pkg
        elif [ "$(yay -Qk $pkg)" ]; then
            yay -Sy --needed --noconfirm $pkg
        fi
    done
}

function nosudo {
    echo "[*] nosudo"

    sudo bash -c "echo '$USER ALL=(ALL) NOPASSWD:ALL' >> /etc/sudoers"
}

function git_setup {
    echo "[*] git_setup"

    cp $CONFIG/git/gitconfig $HOME/.gitconfig
}

function i3_setup {
    echo "[*] i3_setup"

    cp $CONFIGS/i3/config $HOME/.config/i3/config
}

function vim_setup {
    echo "[*] vim_setup"

    install "vim"

    cp $CONFIGS/vim/vimrc $HOME/.vimrc
}

function zsh_setup {
    echo "[*] zsh_setup"

    install "zsh"

    echo "[+] oh-my-szh autojump autosuggestion"

    source $CONFIGS/zsh/ohmyzsh.sh --skip-chsh
    git clone --depth=1 https://github.com/romkatv/powerlevel10k.git ${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/themes/powerlevel10k
    git clone --depth=1 https://github.com/zsh-users/zsh-autosuggestions.git ${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/plugins/zsh-autosuggestions

    rm $HOME/.zshrc
    cp $CONFIGS/zsh/zshrc $HOME/.zshrc
    cp $CONFIGS/zsh/p10k.zsh $HOME/.p10k.zsh

    echo "export FZF_CONFIGS_COMMAND='fd -type f'" >> $HOME/.envvars

    echo "[+] Changing default shell"
    sudo chsh -s $(which zsh) $USER
}

function tmux_setup {
    echo "[*] tmux_setup"

    install "tmux xclip"

    cp $CONFIGS/tmux/tmux.conf $HOME/.tmux.conf
}

function evince_setup {
    echo "[*] evince_setup"

    install "evince"
}

function rclone_setup {
    echo "[*] rclone_setup"
    install "rclone inotify-tools"

    echo "[+] configure rclone, type absolute path to local directory you want to mount:"
    read -r LOCAL_DIR

    echo "[*] setup google-drive"
    rclone config

    mkdir $LOCAL_DIR
    rclone sync --verbose  "google-drive:/" $LOCAL_DIR

    echo "[*] setup automatic syncing"
    SYNC_SCRIPT="$HOME/.config/rclone/rclone-sync.sh"
    cp $OPTIONAL/rclone/rclone-sync.sh $SYNC_SCRIPT

    sudo loginctl enable-linger $USER
    if loginctl show-user $USER | grep "Linger=no"; then
        echo "[-] cannot enable Linger"
        exit 1
    fi

    mkdir -p $HOME/.config/systemd/user
    SERVICE_FILE=$HOME/.config/systemd/user/rclone_sync.google-drive.service
    if test -f $SERVICE_FILE; then
        echo "[-] Unit file already exists: $SERVICE_FILE - Not overwriting"
    else
        cat << EOF > $SERVICE_FILE
[Unit]
Description=rclone-sync google-drive

[Service]
ExecStart=$SYNC_SCRIPT google-drive: $LOCAL_DIR

[Install]
WantedBy=default.target
EOF
    fi
    systemctl --user daemon-reload
    systemctl --user enable --now rclone_sync.google-drive
    systemctl --user status rclone_sync.google-drive
}


function pyenv_setup {
    echo "[*] pyenv_setup"

    install "pyenv"
}

function ranger_setup {
    echo "[*] ranger_setup"

    install "ranger"
}

function _docker_setup {
    install "docker"

    sudo systemctl enable --now docker.service
    sudo usermod -aG docker $USER

    docker run hello-world

    docker build --build-arg user=$USER -t init-ubuntu:20.04 $CONFIGS/docker
}

function vscode_setup {
    install "visual-studio-code-bin"
}

###############################################################################

function setup {
    set -ex

    nosudo
    git_setup
    i3_setup
    vim_setup
    zsh_setup
    tmux_setup
    evince_setup
    rclone_setup
    pyenv_setup
    ranger_setup
    _docker_setup
    vscode_setup
}

setup
