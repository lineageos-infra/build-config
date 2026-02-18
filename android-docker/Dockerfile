FROM ubuntu:24.04

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
    gperf \
    imagemagick \
    lib32readline-dev \
    libbz2-dev \
    libgnutls28-dev \
    liblz4-tool \
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
    python3 \
    python3-pip \
    gnupg \
    zip \
    zlib1g-dev \
    libc6-dev-i386 \
    x11proto-core-dev \
    libx11-dev \
    lib32z1-dev \
    libgl1-mesa-dev \
    xsltproc \
    unzip \
    fontconfig

# https://github.com/LineageOS/lineage_wiki/blob/d16304060a46ff1c55847dfbc42e75015fd89412/_includes/templates/device_build_before_init.md?plain=1#L84-L89
RUN wget https://archive.ubuntu.com/ubuntu/pool/universe/n/ncurses/libtinfo5_6.3-2_amd64.deb && dpkg -i libtinfo5_6.3-2_amd64.deb && rm -f libtinfo5_6.3-2_amd64.deb
RUN wget https://archive.ubuntu.com/ubuntu/pool/universe/n/ncurses/libncurses5_6.3-2_amd64.deb && dpkg -i libncurses5_6.3-2_amd64.deb && rm -f libncurses5_6.3-2_amd64.deb

RUN curl -sLo /usr/local/bin/repo https://commondatastorage.googleapis.com/git-repo-downloads/repo && chmod +x /usr/local/bin/repo

RUN mkdir /lineage
RUN mkdir /ccache

ENV USE_CCACHE=1
ENV CCACHE_EXEC=/usr/bin/ccache
ENV CCACHE_DIR=/ccache
