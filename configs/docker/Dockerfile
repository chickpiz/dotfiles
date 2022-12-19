FROM ubuntu:20.04

ARG user

RUN apt update \
 && apt install -y sudo

RUN adduser --disabled-password --gecos '' $user \
 && adduser $user sudo \
 && echo "$user ALL=(ALL) NOPASSWD:ALL" >> /etc/sudoers

USER $user
WORKDIR /home/$user

COPY dotfiles-docker /home/$user/.dotfiles
RUN sudo chown -R $user:$user /home/$user/.dotfiles

RUN cd /home/$user/.dotfiles \
 && ./setup-docker.sh

ENV TERM=xterm-256color
CMD ["/usr/bin/zsh"]
