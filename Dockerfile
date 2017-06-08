FROM alpine:3.4
MAINTAINER Michael Venezia <mvenezia@gmail.com>

ENV     TERRAFORM_VERSION=0.8.6
ENV     TF_COREOSBOX_VERSION=v0.0.3
ENV     TF_DISTROIMAGE_VERSION=v0.0.1
ENV     TF_PROVIDEREXECUTE_VERSION=v0.0.4

ENV     GCLOUD_SDK_VERSION=128.0.0
ENV     GCLOUD_SDK_URL=https://dl.google.com/dl/cloudsdk/channels/rapid/downloads/google-cloud-sdk-${GCLOUD_SDK_VERSION}-linux-x86_64.tar.gz
ENV     CLOUDSDK_PYTHON_SITEPACKAGES 1
        # google cloud kubectl is superceeded by downloaded kubectl
ENV     PATH $PATH:/google-cloud-sdk/bin

ENV     K8S_VERSION=v1.4.12
ENV     K8S_HELM_VERSION=v2.3.1

ENV     K8S_VERSION_1_4=v1.4.12
ENV     K8S_VERSION_1_5=v1.5.7
ENV     K8S_VERSION_1_6=v1.6.4

ENV     K8S_HELM_VERSION_1_4=v2.1.3
ENV     K8S_HELM_VERSION_1_5=v2.3.1
ENV     K8S_HELM_VERSION_1_6=v2.4.2

#Latest version of tools
ENV     LATEST=v1.6
ENV     K8S_VERSION_LATEST=$K8S_VERSION_1_6
ENV     K8S_HELM_VERSION_LATEST=$K8S_HELM_VERSION_1_6

ENV     GOPATH /go
ENV     GO15VENDOREXPERIMENT 1


ADD     /alpine-builds /alpine-builds
ADD     requirements.txt /requirements.txt
ADD     imagerun.sh /imagerun.sh

RUN     /imagerun.sh
