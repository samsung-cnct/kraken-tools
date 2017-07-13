#!/bin/sh
apk update
apk add git
git clone --branch master  https://github.com/samsung-cnct/k2.git ~/kraken

echo "now in local k2 checkout"
cd ~/kraken
mkdir -p /root/.ssh
build-scripts/fetch-credentials.sh


echo "prep complete, create config"
mkdir -p cluster/gke
cp ansible/roles/kraken.config/files/gke-config.yaml cluster/gke/config.yaml

echo "modify config in-place"
build-scripts/update-generated-config.sh cluster/gke/config.yaml ${JOB_BASE_NAME}-${BUILD_ID}

echo "up and down"
err=0
PWD=`pwd` && ./up.sh --config $PWD/cluster/gke/config.yaml --output $PWD/cluster/gke/
up_err=$?
if [ $up_err -ne 0 ]; then
  err=$up_err
  echo "./up.sh failed"
fi

PWD=`pwd` && ./down.sh --config $PWD/cluster/gke/config.yaml --output $PWD/cluster/gke/
down_err=$?
if [ $down_err -ne 0 ]; then
  err=$down_err
  echo "./down.sh failed"
fi

exit $err
