#!/bin/bash

/alpine-builds/build.sh
mkdir -p /alpine-builds/output
cp /home/samsung/packages/alpine-builds/x86_64/*.apk /alpine-builds/output
