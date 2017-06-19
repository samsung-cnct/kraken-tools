#!/bin/sh -e
set -o pipefail

# Prepping Alpine
# Adding baseline alpine packages
apk update 
apk add --no-cache  \
    libffi-dev \
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


# Google cloud work
wget https://dl.google.com/dl/cloudsdk/channels/rapid/google-cloud-sdk.zip
unzip -o google-cloud-sdk.zip
rm google-cloud-sdk.zip
google-cloud-sdk/install.sh --usage-reporting=false --path-update=false --bash-completion=false
# Disable updater check for the whole installation.
# Users won't be bugged with notifications to update to the latest version of gcloud.
google-cloud-sdk/bin/gcloud config set --installation component_manager/disable_update_check true
# Disable updater completely.
# Running `gcloud components update` doesn't really do anything in a union FS.
# Changes are lost on a subsequent run.
sed -i -- 's/\"disable_updater\": false/\"disable_updater\": true/g' /google-cloud-sdk/lib/googlecloudsdk/core/config.json

rm -rf /google-cloud-sdk/.install \
       /google-cloud-sdk/platform/gsutil/third_party/boto \
       /google-cloud-sdk/platform/gsutil/third_party/httplib2 \
       /google-cloud-sdk/platform/gsutil/third_party/oauth2client \
       /google-cloud-sdk/platform/gsutil/third_party/pyasn1 \
       /google-cloud-sdk/platform/gsutil/third_party/pyasn1_modules \
       /google-cloud-sdk/platform/gsutil/third_party/rsa 
ln -s /usr/lib/python2.7/site-packages/boto \
      /usr/lib/python2.7/site-packages/httplib2 \
      /usr/lib/python2.7/site-packages/oauth2client \
      /usr/lib/python2.7/site-packages/pyasn1 \
      /usr/lib/python2.7/site-packages/pyasn1_modules \
      /usr/lib/python2.7/site-packages/rsa \
      /google-cloud-sdk/platform/gsutil/third_party/

# Remove a 19MB data file and replace it with a 250KB one
google-cloud-sdk/bin/gcloud meta list-gcloud --format=json | gzip > /google-cloud-sdk/gcloud_tree.json.gz
mv /gcloud_tree.py /google-cloud-sdk/lib/googlecloudsdk/command_lib/gcloud_tree.py

# Clean up unneeded data
apk del alpine-sdk mtools mkinitfs kmod squashfs-tools git g++ gcc make musl-dev libc-dev python-dev linux-headers
rm -rfv ~/.cache
rm -rfv /var/cache/apk/*
