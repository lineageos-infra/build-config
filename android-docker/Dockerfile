FROM debian:13

# https://github.com/LineageOS/lineage_wiki/blob/b4d0279f1cac24b5adf2c8552dc141ded9045252/_includes/templates/device_build_before_init.md?plain=1#L70
RUN DEBIAN_FRONTEND=noninteractive apt -U install -y \
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
    lib32readline-dev \
    lib32z1-dev \
    libdw-dev \
    libelf-dev \
    libgnutls28-dev \
    libsdl1.2-dev \
    libssl-dev \
    libxml2 \
    libxml2-utils \
    lz4 \
    lzop \
    pngcrush \
    protobuf-compiler \
    python3-protobuf \
    rsync \
    schedtool \
    squashfs-tools \
    xsltproc \
    xxd \
    yasm \
    zip \
    zlib1g-dev

RUN curl -sLo /usr/local/bin/repo https://commondatastorage.googleapis.com/git-repo-downloads/repo && chmod +x /usr/local/bin/repo

RUN DEBIAN_FRONTEND=noninteractive apt install -y \
    openjdk-25-jre \
    python3-pip \
    s3cmd \
    wget

RUN pip config set global.break-system-packages true

RUN mkdir /lineage
RUN mkdir /ccache

ENV USE_CCACHE=1
ENV CCACHE_EXEC=/usr/bin/ccache
ENV CCACHE_DIR=/ccache
