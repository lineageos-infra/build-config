FROM ubuntu:20.04

RUN apt update && DEBIAN_FRONTEND=noninteractive apt install -y \
    bc \
    bison \
    build-essential \
    ccache \
    curl \
    flex \
    fontconfig \
    g++-multilib \
    gcc-multilib \
    git \
    gnupg \
    gperf \
    imagemagick \
    lib32ncurses5-dev \
    lib32readline-dev \
    lib32z1-dev \
    libbz2-dev \
    libc6-dev-i386 \
    libgl1-mesa-dev \
    liblz4-tool \
    libncurses5 \
    libncurses5-dev \
    libreadline-dev \
    libsdl1.2-dev \
    libsqlite3-dev \
    libssl-dev \
    libx11-dev \
    libxml2 \
    libxml2-utils \
    llvm \
    lzop \
    openjdk-8-jdk \
    pngcrush \
    python \
    python3-pip \
    rsync \
    schedtool \
    squashfs-tools \
    unzip \
    wget \
    x11proto-core-dev \
    xsltproc \
    zip \
    zlib1g-dev

RUN curl -sLo /usr/local/bin/repo https://commondatastorage.googleapis.com/git-repo-downloads/repo && chmod +x /usr/local/bin/repo

RUN mkdir /lineage
RUN mkdir /ccache

ENV USE_CCACHE=1
ENV CCACHE_EXEC=/usr/bin/ccache
ENV CCACHE_DIR=/ccache
