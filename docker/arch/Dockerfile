
FROM ubuntu:24.04

ENV DEBIAN_FRONTEND=noninteractive
ENV LANG=C.UTF-8

RUN apt-get update && \
    apt-get install -y --no-install-recommends \
    openssh-server \
    sudo \
    ca-certificates \
    curl \
    wget \
    git \
    build-essential \
    pkg-config \
    vim \
    nano \
    less \
    tmux \
    htop \
    unzip \
    zip \
    jq \
    procps \
    iproute2 \
    iputils-ping \
    netcat-openbsd \
    python3 \
    python3-pip \
    python3-venv \
    bash-completion \
    file \
    xz-utils \
    zstd && \
    rm -rf /var/lib/apt/lists/*

RUN useradd \
    --create-home \
    --uid 1000 \
    --user-group \
    --shell /bin/bash \
    remote && \
    install -d -o remote -g remote -m 0755 \
    /home/remote/workspace && \
    install -d -m 0755 /run/sshd

COPY entrypoint.sh /usr/local/bin/entrypoint.sh

RUN chmod 0755 /usr/local/bin/entrypoint.sh

EXPOSE 2222

ENTRYPOINT ["/usr/local/bin/entrypoint.sh"]
