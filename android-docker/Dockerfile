FROM ubuntu:20.04

RUN apt update && DEBIAN_FRONTEND=noninteractive apt install -y \
    bc \
    bison \
    build-essential \
    ccache \
    curl \
    flex \
    g++-multilib \
    gcc-multilib \
    git \
    git-lfs \
    gnupg \
    gperf \
    imagemagick \
    libncurses5-dev \
    lib32ncurses5-dev \
    lib32readline-dev \
    lib32z1-dev \
    libbz2-dev \
    libgnutls28-dev \
    liblz4-tool \
    libncurses5 \
    libncurses5-dev \
    libreadline-dev \
    libsdl1.2-dev \
    libsqlite3-dev \
    libssl-dev \
    libxml2 \
    libxml2-utils \
    llvm \
    lzop \
    openjdk-8-jdk \
    pngcrush \
    rsync \
    s3cmd \
    schedtool \
    squashfs-tools \
    wget \
    zip \
    zlib1g-dev \
    python \
    python3-pip \
    libc6-dev-i386 \
    x11proto-core-dev \
    libx11-dev \
    gnupg \
    flex \
    bison \
    build-essential \
    zip \
    curl \
    zlib1g-dev \
    gcc-multilib \
    g++-multilib \
    libc6-dev-i386 \
    lib32ncurses5-dev \
    x11proto-core-dev \
    libx11-dev \
    lib32z1-dev \
    libgl1-mesa-dev \
    xsltproc \
    unzip \
    fontconfig

RUN curl -sLo /usr/local/bin/repo https://commondatastorage.googleapis.com/git-repo-downloads/repo && chmod +x /usr/local/bin/repo

RUN mkdir /lineage
RUN mkdir /ccache

ENV USE_CCACHE=1
ENV CCACHE_EXEC=/usr/bin/ccache
ENV CCACHE_DIR=/ccache
