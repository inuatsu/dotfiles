FROM ubuntu:22.04

ENV TZ=Asia/Tokyo
RUN ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && \
  echo $TZ > /etc/timezone

RUN apt-get update && \
  apt-get upgrade -y && \
  apt-get install -y --no-install-recommends \
  git \
  ca-certificates \
  sudo \
  zsh && \
  apt-get clean && \
  rm -rf /var/lib/apt/lists/*

ENV USER=test
ENV HOME=/home/${USER}

SHELL ["/bin/bash", "-o", "pipefail", "-c"]
RUN useradd -m ${USER} && \
  gpasswd -a ${USER} sudo && \
  echo "${USER}:test" | chpasswd

WORKDIR ${HOME}

RUN git clone https://github.com/inuatsu/dotfiles.git && \
  touch .zshrc

RUN chown -R ${USER}:${USER} ${HOME}

ENV SHELL=/usr/bin/zsh
RUN chsh -s "$(which zsh)" && \
  zsh

USER ${USER}
CMD ["/bin/zsh"]
