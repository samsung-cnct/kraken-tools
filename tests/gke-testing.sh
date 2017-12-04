#!/bin/sh
apk update
apk add git
git clone --branch master  https://github.com/samsung-cnct/kraken-lib.git ~/kraken

echo "now in local kraken-lib checkout"
cd ~/kraken
mkdir -p /root/.ssh
build-scripts/fetch-credentials.sh


echo "prep complete, create config"
mkdir -p cluster/gke
bin/up.sh --generate --provider GKE --config cluster/gke/config.yaml

echo "modify config in-place"
build-scripts/update-generated-config.sh cluster/gke/config.yaml krakentools-${BUILD_ID}

echo "up and down"
err=0
PWD=`pwd` && bin/up.sh --config $PWD/cluster/gke/config.yaml --output $PWD/cluster/gke/ -v '-vvv'
up_err=$?
if [ $up_err -ne 0 ]; then
  err=$up_err
  echo "./up.sh failed"
fi

PWD=`pwd` && bin/down.sh --config $PWD/cluster/gke/config.yaml --output $PWD/cluster/gke/
down_err=$?
if [ $down_err -ne 0 ]; then
  err=$down_err
  echo "./down.sh failed"
fi

exit $err
