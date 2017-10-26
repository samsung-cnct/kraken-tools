FROM alpine:3.6
MAINTAINER Michael Venezia <mvenezia@gmail.com>

ENV     TERRAFORM_VERSION=0.8.6
ENV     TF_SHA256=a5b654132d8512d3341f092b9f66c222315c4b3ca6dc217ed3ff2bdfa9f4a235
ENV     TF_COREOSBOX_VERSION=v0.0.3
ENV     TF_DISTROIMAGE_VERSION=v0.0.1
ENV     TF_PROVIDEREXECUTE_VERSION=v0.0.4

ENV     GCLOUD_SDK_VERSION=162.0.0
ENV     GCLOUD_SHA256=4a2fcf7c91830b9a3460dcdb716f37882e2555b8ca22e30b403108e5e4be3158
ENV     GCLOUD_SDK_URL=https://dl.google.com/dl/cloudsdk/channels/rapid/downloads/google-cloud-sdk-${GCLOUD_SDK_VERSION}-linux-x86_64.tar.gz
ENV     CLOUDSDK_PYTHON_SITEPACKAGES 1
# Google cloud kubectl is superseded by downloaded kubectl
ENV     PATH $PATH:/google-cloud-sdk/bin

ENV     ETCD_VERSION=v3.2.5
ENV     ETCD_SHA256=44a05f6d392a754329086f7a5356d1727d5fb19f331f48fd8109a8b24ef9616c
ENV     ETCDCTL_API=3

ENV     K8S_VERSION=v1.8.1
ENV     K8S_HELM_VERSION=v2.7.0

ENV     K8S_VERSION_1_5=v1.5.8
ENV     K8S_VERSION_1_6=v1.6.11
ENV     K8S_1_6_SHA256=0dacad1c3da0397b6234e474979c4095844733315a853feba5690dbdf8db15dc
ENV     K8S_VERSION_1_7=v1.7.8
ENV     K8S_1_7_SHA256=219bbdd3b36949004432230629f14caf6e36839537bac54d75c02ca0bc91af73
ENV     K8S_VERSION_1_8=v1.8.2
ENV     K8S_1_8_SHA256=15bf424a40544d2ff02eeba00d92a67409a31d2139c78b152b7c57a8555a1549

ENV     K8S_HELM_VERSION_1_5=v2.3.1
ENV     K8S_HELM_1_5=a655cfaaf8917c7f6e8a9ac52dddb24b6294774aab175b5c23848b1d1a50de9d
ENV     K8S_HELM_VERSION_1_6=v2.5.1
ENV     K8S_HELM_1_6=0ea53d0d6086805f8f22c609a2f1b5b21ced96d5cf4c6a4a70588bc3822e79c2
ENV     K8S_HELM_VERSION_1_7=v2.6.2
ENV     K8S_HELM_1_7=ba807d6017b612a0c63c093a954c7d63918d3e324bdba335d67b7948439dbca8
ENV     K8S_HELM_VERSION_1_8=v2.7.0
#ENV     K8S_HELM_1_8=ba807d6017b612a0c63c093a954c7d63918d3e324bdba335d67b7948439dbca8

# Latest version of tools
ENV     LATEST=v1.8
ENV     K8S_VERSION_LATEST=$K8S_VERSION_1_8
ENV     K8S_HELM_VERSION_LATEST=$K8S_HELM_VERSION_1_8

ENV     GOPATH /go
ENV     GO15VENDOREXPERIMENT 1

ENV     HELM_HOME=/etc/helm
ENV     HELM_PLUGIN=/etc/helm/plugins
ENV     APP_REGISTRY_PLUGIN_RELEASE=v0.7.0
ENV     APP_REGISTRY_URL=https://github.com/app-registry/appr-helm-plugin/releases/download/${APP_REGISTRY_PLUGIN_RELEASE}/helm-registry_linux.tar.gz

# Alpine
ADD     build/alpine-builds /alpine-builds

ENV     APK_PACKAGES="bash ca-certificates openssl openssh python py-openssl py-pip py-cryptography py-cffi zip unzip wget util-linux bind-tools"
ENV     APK_DEV_PACKAGES="gcc g++ git make libffi-dev linux-headers musl-dev libc-dev openssl-dev python-dev unzip mkinitfs kmod mtools squashfs-tools"

RUN     apk add --update --no-cache ${APK_PACKAGES} ${APK_DEV_PACKAGES} && \
    	  /alpine-builds/build-docker.sh && \
        rm -rf /alpine-builds

# Terraform
RUN     wget -q https://releases.hashicorp.com/terraform/${TERRAFORM_VERSION}/terraform_${TERRAFORM_VERSION}_linux_amd64.zip && \
        unzip terraform_${TERRAFORM_VERSION}_linux_amd64.zip && \
        rm terraform_${TERRAFORM_VERSION}_linux_amd64.zip && \
        echo "${TF_SHA256} terraform" | sha256sum -c - && \
        mv terraform /usr/bin/

# Adding Terraform Provider Execute addon
RUN     wget -q https://github.com/samsung-cnct/terraform-provider-execute/releases/download/${TF_PROVIDEREXECUTE_VERSION}/terraform-provider-execute_linux_amd64.tar.gz && \
        tar -zxvf terraform-provider-execute_linux_amd64.tar.gz && \
        rm terraform-provider-execute_linux_amd64.tar.gz && \
        mv terraform-provider-execute /usr/bin/

# Adding Terraform CoreOS Box addon
RUN 	  wget -q https://github.com/samsung-cnct/terraform-provider-coreosbox/releases/download/${TF_COREOSBOX_VERSION}/terraform-provider-coreosbox_linux_amd64.tar.gz && \
        tar -zxvf terraform-provider-coreosbox_linux_amd64.tar.gz && \
        rm terraform-provider-coreosbox_linux_amd64.tar.gz && \
        mv terraform-provider-coreosbox /usr/bin/

# Adding Terraform Distro Image Selector addon
RUN 	  wget -q https://github.com/samsung-cnct/terraform-provider-distroimage/releases/download/${TF_DISTROIMAGE_VERSION}/terraform-provider-distroimage_linux_amd64.tar.gz && \
        tar -zxvf terraform-provider-distroimage_linux_amd64.tar.gz && \
        rm terraform-provider-distroimage_linux_amd64.tar.gz && \
        mv terraform-provider-distro /usr/bin/

# Etcd
RUN     wget -q -O etcd.tgz https://github.com/coreos/etcd/releases/download//${ETCD_VERSION}/etcd-${ETCD_VERSION}-linux-amd64.tar.gz && \
        echo "${ETCD_SHA256} etcd.tgz" | sha256sum -c - && \
        tar -zxvf etcd.tgz && \
        cp etcd-${ETCD_VERSION}-linux-amd64/etcdctl /usr/local/bin && \
        rm -rf etcd-${ETCD_VERSION}-linux-amd64/ && \
        rm -f etcd.tgz

# Creating path for helm and kubectl executables
RUN     mkdir -p /opt/cnct/kubernetes/v1.5/bin \
                 /opt/cnct/kubernetes/v1.6/bin \
                 /opt/cnct/kubernetes/v1.7/bin \
                 /opt/cnct/kubernetes/v1.8/bin \
                 /etc/helm/plugins

# Kubectl
RUN     wget -q https://storage.googleapis.com/kubernetes-release/release/${K8S_VERSION_1_5}/bin/linux/amd64/kubectl && \
        chmod a+x kubectl && \
        mv kubectl /opt/cnct/kubernetes/v1.5/bin
RUN     wget -q https://storage.googleapis.com/kubernetes-release/release/${K8S_VERSION_1_6}/bin/linux/amd64/kubectl && \
        echo "${K8S_1_6_SHA256} kubectl" | sha256sum -c - && \
        chmod a+x kubectl && \
        mv kubectl /opt/cnct/kubernetes/v1.6/bin
RUN     wget -q https://storage.googleapis.com/kubernetes-release/release/${K8S_VERSION_1_7}/bin/linux/amd64/kubectl && \
        echo "${K8S_1_7_SHA256} kubectl" | sha256sum -c - && \
        chmod a+x kubectl && \
        mv kubectl /opt/cnct/kubernetes/v1.7/bin
RUN     wget -q https://storage.googleapis.com/kubernetes-release/release/${K8S_VERSION_1_8}/bin/linux/amd64/kubectl && \
        echo "${K8S_1_8_SHA256} kubectl" | sha256sum -c - && \
        chmod a+x kubectl && \
        mv kubectl /opt/cnct/kubernetes/v1.8/bin


# Helm
RUN     wget -q -O helm_1_5.tgz http://storage.googleapis.com/kubernetes-helm/helm-v2.5.1-linux-amd64.tar.gz  && \
        echo "$K8S_HELM_1_5_SHA256 helm_1_5.tgz" | sha256sum -c - && \
        tar -zxvf helm_1_5.tgz  && \
        mv linux-amd64/helm /opt/cnct/kubernetes/v1.5/bin/helm  && \
        rm -rf linux-amd64 helm_1_5.tgz
RUN     wget -q -O helm_1_6.tgz http://storage.googleapis.com/kubernetes-helm/helm-${K8S_HELM_VERSION_1_6}-linux-amd64.tar.gz  && \
        echo "${K8S_HELM_1_6_SHA256} helm_1_6.tgz" | sha256sum -c - && \
        tar -zxvf helm_1_6.tgz  && \
        mv linux-amd64/helm /opt/cnct/kubernetes/v1.6/bin/helm  && \
        rm -rf linux-amd64 helm_1_6.tgz
RUN     wget -q -O helm_1_7.tgz http://storage.googleapis.com/kubernetes-helm/helm-${K8S_HELM_VERSION_1_7}-linux-amd64.tar.gz  && \
        echo "${K8S_HELM_1_7_SHA256} helm_1_7.tgz" | sha256sum -c - && \
        tar -zxvf helm_1_7.tgz  && \
        mv linux-amd64/helm /opt/cnct/kubernetes/v1.7/bin/helm  && \
        rm -rf linux-amd64 helm_1_7.tgz
RUN     wget -q -O helm_1_8.tgz http://storage.googleapis.com/kubernetes-helm/helm-${K8S_HELM_VERSION_1_8}-linux-amd64.tar.gz  && \
        echo "${K8S_HELM_1_8_SHA256} helm_1_8.tgz" | sha256sum -c - && \
        tar -zxvf helm_1_8.tgz  && \
        mv linux-amd64/helm /opt/cnct/kubernetes/v1.8/bin/helm  && \
        rm -rf linux-amd64 helm_1_8.tgz

RUN ln -s /opt/cnct/kubernetes/${LATEST} /opt/cnct/kubernetes/latest && \
         ln -s /opt/cnct/kubernetes/${LATEST}/bin/kubectl /usr/bin/ && \
         ln -s /opt/cnct/kubernetes/${LATEST}/bin/helm /usr/bin/


# Python (including ansible)
ADD     build/requirements.txt /requirements.txt
ADD     build/gcloud_tree.py /gcloud_tree.py
ADD     tests/aws-testing.sh /aws-testing.sh
ADD     tests/gke-testing.sh /gke-testing.sh

# Install things that need compilers, etc
RUN     pip install -r /requirements.txt

# Delete build-related packages
RUN     apk del ${APK_DEV_PACKAGES} && \
        rm -rfv ~/.cache && \
        rm -rfv /var/cache/apk/*

# Google cloud work (copied from https://github.com/GoogleCloudPlatform/cloud-sdk-docker/blob/master/alpine/Dockerfile )
RUN     wget -q -O gcloud.tgz ${GCLOUD_SDK_URL} && \
        echo "${GCLOUD_SHA256} gcloud.tgz" | sha256sum -c - && \
        tar xzf gcloud.tgz && \
        rm gcloud.tgz && \
        ln -s /lib /lib64 && \
        gcloud config set core/disable_usage_reporting true && \
        gcloud config set component_manager/disable_update_check true && \
        gcloud config set metrics/environment github_docker_image

# Install the help app registry plugin
RUN     mkdir -p /etc/helm/plugins/appr && \
        cd ${HELM_PLUGIN} && wget ${APP_REGISTRY_URL} -O - | tar -zxv && \
        helm registry version placeholder

# Crash application
RUN     wget -q -O crash-app.tgz https://github.com/samsung-cnct/k2-crash-application/releases/download/0.1.0/k2-crash-application_0.1.0_linux_amd64.tar.gz && \
        tar -zxvf crash-app.tgz  && \
        mv k2-crash-application /usr/bin/k2-crash-application && \
        rm -f crash-app.tgz


# Quick verification script to confirm all expected binaries are present.
ADD tests/internal_tooling.sh /internal_tooling_test.sh
