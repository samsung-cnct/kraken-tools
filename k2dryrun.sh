#!/bin/sh
apk update
apk add git
git clone --branch master  https://github.com/samsung-cnct/k2.git ~/kraken
cd ~/kraken
ls -al
build-scripts/fetch-credentials.sh
./up.sh --generate cluster/aws/config.yaml
ls -al
build-scripts/update-generated-config.sh cluster/aws/config.yaml ${JOB_BASE_NAME}-${BUILD_ID}
PWD=`pwd` && ./up.sh --config $PWD/cluster/aws/config.yaml --output $PWD/cluster/aws/ -t dryrun
