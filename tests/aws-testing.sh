#!/bin/sh
apk update
apk add git
git clone --branch master  https://github.com/samsung-cnct/k2.git ~/kraken

echo "now in local k2 checkout"
cd ~/kraken
mkdir -p /root/.ssh
build-scripts/fetch-credentials.sh

echo "prep complete, create config"
bin/up.sh --generate cluster/aws/config.yaml

echo "modify config in-place"
build-scripts/update-generated-config.sh cluster/aws/config.yaml ${JOB_BASE_NAME}-${BUILD_ID}

echo "adding helm_override and setting it to false"
export helm_override_${JOB_BASE_NAME}-${BUILD_ID}=false

echo "dry run"
PWD=`pwd` && bin/up.sh --config $PWD/cluster/aws/config.yaml --output $PWD/cluster/aws/ -t dryrun
if [ $? -ne 0 ]; then
  echo "Failed at dry run step"
  exit 1;
fi

echo "up and down"
err=0
PWD=`pwd` && bin/up.sh --config $PWD/cluster/aws/config.yaml --output $PWD/cluster/aws/
up_err=$?
if [ $up_err -ne 0 ]; then
  err=$up_err
  echo "./up.sh failed"
fi

PWD=`pwd` && bin/down.sh --config $PWD/cluster/aws/config.yaml --output $PWD/cluster/aws/
down_err=$?
if [ $down_err -ne 0 ]; then
  err=$down_err
  echo "./down.sh failed"
fi

exit $err
