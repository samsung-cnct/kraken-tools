#!/bin/sh -e
set -o pipefail

# Prepping Alpine
# Adding baseline alpine packages
apk update 
apk add --no-cache  \
    g++ \
    gcc \
    linux-headers \
    musl-dev \
    openssl \
    python-dev 

# Python / ansible addon work
# update pip
pip install --upgrade pip
# install all python packages
pip install -r /requirements.txt

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
