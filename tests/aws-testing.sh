#!/bin/sh
apk update
apk add git
git clone --branch master  https://github.com/samsung-cnct/kraken-lib.git ~/kraken

echo "now in local kraken-lib checkout"
cd ~/kraken
mkdir -p /root/.ssh
build-scripts/fetch-credentials.sh

echo "prep complete, create config"
bin/up.sh --generate --config cluster/aws/config.yaml

echo "modify config in-place"
build-scripts/update-generated-config.sh cluster/aws/config.yaml krakentools-${BUILD_ID}

echo "adding helm_override and setting it to false"
job_name=`echo ${JOB_BASE_NAME}-${BUILD_ID} | tr '[:upper:]' '[:lower:]' | tr '-' '_'`
export helm_override_${job_name}=false

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
