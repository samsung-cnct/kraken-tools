#!/bin/sh -e
set -o pipefail

# Packages required during installation but not run time.
DEVEL_PACKAGES="alpine-sdk \
    git \
    py-pip \
    py-cffi \
    py-cryptography \
    python-dev \
    make \
    gcc \
    g++ \
    linux-headers \
    libc-dev \
    musl-dev \
    openssl-dev \
    libffi-dev \
    mtools \
    mkinitfs \
    kmod \
    squashfs-tools \
"

apk update 
apk add --no-cache ${DEVEL_PACKAGES}

pip install --upgrade pip
pip install -r /requirements.txt

/alpine-builds/build-docker.sh
rm -rf /alpine-builds

wget https://dl.google.com/dl/cloudsdk/channels/rapid/google-cloud-sdk.zip
unzip -o google-cloud-sdk.zip
rm google-cloud-sdk.zip
google-cloud-sdk/install.sh --usage-reporting=false --path-update=false --bash-completion=false

# Disable updater check for the whole installation.
# Users won't be bugged with notifications to update to the latest version of
# gcloud.
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

apk del ${DEVEL_PACKAGES}
rm -rfv ~/.cache
rm -rfv /var/cache/apk/*
