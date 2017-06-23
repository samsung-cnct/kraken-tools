FROM alpine:3.6
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
ENV     K8S_VERSION_1_6=v1.6.6

ENV     K8S_HELM_VERSION_1_4=v2.1.3
ENV     K8S_HELM_VERSION_1_5=v2.3.1
ENV     K8S_HELM_VERSION_1_6=v2.5.0

ENV     LATEST=v1.6
ENV     K8S_VERSION_LATEST=$K8S_VERSION_1_6
ENV     K8S_HELM_VERSION_LATEST=$K8S_HELM_VERSION_1_6

ENV     GOPATH /go
ENV     GO15VENDOREXPERIMENT 1

# These are the minimal dependencies necessary to download and uncompress
# packages securely. Most other requirements belong in the imagerun.sh script
# at this end of this Dockerfile.
RUN     apk update && \
        apk add bash \
                openssl \
                ca-certificates \
                wget \
                zip \
                unzip \
                python && \
        rm -rfv /var/cache/apk/*

ADD     /alpine-builds /alpine-builds

## Terraform

RUN     wget https://releases.hashicorp.com/terraform/${TERRAFORM_VERSION}/terraform_${TERRAFORM_VERSION}_linux_amd64.zip && \
        unzip terraform_${TERRAFORM_VERSION}_linux_amd64.zip && \
        rm terraform_${TERRAFORM_VERSION}_linux_amd64.zip && \
        mv terraform /usr/bin/

RUN     wget https://github.com/samsung-cnct/terraform-provider-execute/releases/download/${TF_PROVIDEREXECUTE_VERSION}/terraform-provider-execute_linux_amd64.tar.gz && \
        tar -zxvf terraform-provider-execute_linux_amd64.tar.gz && \
        rm terraform-provider-execute_linux_amd64.tar.gz && \
        mv terraform-provider-execute /usr/bin/

RUN 	wget https://github.com/samsung-cnct/terraform-provider-coreosbox/releases/download/${TF_COREOSBOX_VERSION}/terraform-provider-coreosbox_linux_amd64.tar.gz && \
        tar -zxvf terraform-provider-coreosbox_linux_amd64.tar.gz && \
        rm terraform-provider-coreosbox_linux_amd64.tar.gz && \
        mv terraform-provider-coreosbox /usr/bin/

RUN 	wget https://github.com/samsung-cnct/terraform-provider-distroimage/releases/download/${TF_DISTROIMAGE_VERSION}/terraform-provider-distroimage_linux_amd64.tar.gz && \
        tar -zxvf terraform-provider-distroimage_linux_amd64.tar.gz && \
        rm terraform-provider-distroimage_linux_amd64.tar.gz && \
        mv terraform-provider-distro /usr/bin/

## Kubernetes

RUN     mkdir -p /opt/cnct/kubernetes/v1.4/bin \
                 /opt/cnct/kubernetes/v1.5/bin \
                 /opt/cnct/kubernetes/v1.6/bin && \
        ln -s /opt/cnct/kubernetes/$LATEST /opt/cnct/kubernetes/latest

RUN     wget https://storage.googleapis.com/kubernetes-release/release/${K8S_VERSION_1_4}/bin/linux/amd64/kubectl && \
        chmod a+x kubectl && \
        mv kubectl /opt/cnct/kubernetes/v1.4/bin && \
        ln -s /opt/cnct/kubernetes/v1.4/bin/kubectl /usr/bin/
RUN     wget https://storage.googleapis.com/kubernetes-release/release/${K8S_VERSION_1_5}/bin/linux/amd64/kubectl && \
        chmod a+x kubectl && \
        mv kubectl /opt/cnct/kubernetes/v1.5/bin
RUN     wget https://storage.googleapis.com/kubernetes-release/release/${K8S_VERSION_1_6}/bin/linux/amd64/kubectl && \
        chmod a+x kubectl && \
        mv kubectl /opt/cnct/kubernetes/v1.6/bin

RUN     wget http://storage.googleapis.com/kubernetes-helm/helm-${K8S_HELM_VERSION_1_4}-linux-amd64.tar.gz  && \
        tar -zxvf helm-${K8S_HELM_VERSION_1_4}-linux-amd64.tar.gz  && \
        mv linux-amd64/helm /opt/cnct/kubernetes/v1.4/bin/helm  && \
        rm -rf linux-amd64 helm-${K8S_HELM_VERSION_1_4}-linux-amd64.tar.gz
RUN     wget http://storage.googleapis.com/kubernetes-helm/helm-${K8S_HELM_VERSION_1_5}-linux-amd64.tar.gz  && \
        tar -zxvf helm-${K8S_HELM_VERSION_1_5}-linux-amd64.tar.gz  && \
        mv linux-amd64/helm /opt/cnct/kubernetes/v1.5/bin/helm  && \
        rm -rf linux-amd64 helm-${K8S_HELM_VERSION_1_5}-linux-amd64.tar.gz && \
        ln -s /opt/cnct/kubernetes/v1.5/bin/helm /usr/bin/
RUN     wget http://storage.googleapis.com/kubernetes-helm/helm-${K8S_HELM_VERSION_1_6}-linux-amd64.tar.gz  && \
        tar -zxvf helm-${K8S_HELM_VERSION_1_6}-linux-amd64.tar.gz  && \
        mv linux-amd64/helm /opt/cnct/kubernetes/v1.6/bin/helm  && \
        rm -rf linux-amd64 helm-${K8S_HELM_VERSION_1_6}-linux-amd64.tar.gz

ADD     requirements.txt /requirements.txt
ADD     imagerun.sh /imagerun.sh
ADD     gcloud_tree.py /gcloud_tree.py

## imagerun.sh is an attempt to reduce the size of, and number of layers in, the docker image.
RUN     /imagerun.sh
