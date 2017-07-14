#!/bin/sh -e
set -o pipefail

# Prepping Alpine
# Adding baseline alpine packages
apk update 
apk add --no-cache  \
    bash \
    ca-certificates \
    g++ \
    gcc \
    libffi-dev \
    linux-headers \
    musl-dev \
    openssl \
    openssl-dev \
    py-cffi \
    py-cryptography \
    py-pip \
    python \
    python-dev \
    unzip \
    zip

# Python / ansible addon work
# update pip
pip install --upgrade pip
# install all python packages
pip install -r /requirements.txt

### WORKAROUND
# This works around a bad cffi package in Alpine 3.6.2
# remove after alpine upgrade fixes this
#source /etc/os-release
#if [[ "$ID" == "alpine" && "$VERSION_ID" == "3.6.2" ]]; then
#    pip install -U cffi
#fi

# Clean up unneeded data
apk del \
    alpine-sdk \
    g++ \
    gcc \
    git \
    kmod \
    libc-dev \
    libffi-dev \
    linux-headers \
    make \
    mkinitfs \
    mtools \
    musl-dev \
    openssl-dev \
    python-dev \
    squashfs-tools
rm -rfv ~/.cache
rm -rfv /var/cache/apk/*
