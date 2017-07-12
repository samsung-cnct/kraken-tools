#!/bin/sh -e
set -o pipefail

# Prepping Alpine
# Adding baseline alpine packages
apk update 
apk add --no-cache  \
    libffi-dev \
    openssl \
    openssl-dev \
    ca-certificates \
    python \
    bash \
    py-pip \
    py-cffi \
    py-cryptography \
    unzip \
    zip \
    python-dev \
    gcc \
    linux-headers \
    musl-dev \
    g++

# Python / ansible addon work
# update pip
pip install --upgrade pip
# install all python packages
pip install -r /requirements.txt

# Clean up unneeded data
apk del alpine-sdk libffi-dev openssl-dev mtools mkinitfs kmod squashfs-tools git g++ gcc make musl-dev libc-dev python-dev linux-headers
rm -rfv ~/.cache
rm -rfv /var/cache/apk/*
