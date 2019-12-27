# syntax = docker/dockerfile:experimental
FROM ubuntu:18.04

LABEL maintainer="huyu <huyu.sakuya4645@gmail.com>"

ENV PYTHON_VERSION 3.7.6

ENV TZ Asia/Tokyo

RUN --mount=type=cache,dst=/var/cache/apt --mount=type=cache,dst=/var/lib/apt \
    apt update \
 && apt install -y tzdata

# Python の依存関係パッケージを取得
RUN --mount=type=cache,dst=/var/cache/apt --mount=type=cache,dst=/var/lib/apt \
    apt update \
 && apt upgrade -y \
 && apt install -y build-essential libbz2-dev libdb-dev \
                   libreadline-dev libffi-dev libgdbm-dev liblzma-dev \
                   libncursesw5-dev libsqlite3-dev libssl-dev \
                   zlib1g-dev uuid-dev tk-dev wget

# Python ソースコードの取得・展開
RUN wget https://www.python.org/ftp/python/$PYTHON_VERSION/Python-$PYTHON_VERSION.tgz
RUN tar xvzf Python-$PYTHON_VERSION.tgz

# Python ビルド
RUN cd Python-$PYTHON_VERSION \
 && ./configure --enable-shared \
 && make -j12 \
 && make install

# Python ソースコードの後始末
RUN rm -rf Python-$PYTHON_VERSION.tgz Python-$PYTHON_VERSION

# Python コマンドの設定
RUN export PYTHON_MAJOR_VERSION=$(echo $PYTHON_VERSION | cut -c 1) \
 && ln -s /usr/local/bin/python$PYTHON_MAJOR_VERSION /usr/local/bin/python \
 && ln -s /usr/local/bin/pip$PYTHON_MAJOR_VERSION    /usr/local/bin/pip
RUN echo "/usr/local/lib" > /etc/ld.so.conf.d/custom_python3.conf
RUN ldconfig

# 開発ツールのインストールに add-apt-repository が必要
RUN --mount=type=cache,dst=/var/cache/apt --mount=type=cache,dst=/var/lib/apt \
    apt install -y software-properties-common

# git のインストール
RUN --mount=type=cache,dst=/var/cache/apt --mount=type=cache,dst=/var/lib/apt \
    apt install -y git netcat-openbsd

# lazygit のインストール
RUN --mount=type=cache,dst=/var/cache/apt --mount=type=cache,dst=/var/lib/apt \
    add-apt-repository -y ppa:lazygit-team/daily \
 && apt update \
 && apt install -y lazygit

# Neovim のインストール
RUN --mount=type=cache,dst=/var/cache/apt --mount=type=cache,dst=/var/lib/apt \
    add-apt-repository -y ppa:neovim-ppa/stable \
 && apt update \
 && apt install -y neovim

# fish のインストール
RUN --mount=type=cache,dst=/var/cache/apt --mount=type=cache,dst=/var/lib/apt \
    add-apt-repository -y ppa:fish-shell/release-3 \
 && apt update \
 && apt install -y fish

# pip ライブラリの設定
RUN --mount=type=cache,dst=$HOME/.cache/pip \
    pip install neovim

# エディターの設定
RUN update-alternatives --install /usr/bin/vi     vi     /usr/bin/nvim 60
RUN update-alternatives --install /usr/bin/vim    vim    /usr/bin/nvim 60
RUN update-alternatives --install /usr/bin/editor editor /usr/bin/nvim 60

ENTRYPOINT ["fish"]
