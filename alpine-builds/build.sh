#!/bin/sh
apk update
apk add alpine-sdk
adduser -D samsung
echo "\nsamsung ALL=(ALL) ALL\n" > /etc/sudoers
passwd -d samsung samsung
su -c 'abuild-keygen -n -a' samsung
cp /home/samsung/.abuild/*.pub /etc/apk/keys/
addgroup samsung abuild
chmod a+w /alpine-builds/*

# things we want to add
su -c 'cd /alpine-builds/ansible && abuild checksum && abuild -r' samsung

# Let's install what we build
apk add /home/samsung/packages/alpine-builds/x86_64/*.apk

# Clean up
apk del alpine-sdk

