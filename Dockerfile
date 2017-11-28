FROM alpine:3.6
MAINTAINER Michael Venezia <mvenezia@gmail.com>

ENV     TERRAFORM_VERSION=0.8.6
ENV     TF_SHA256=2b4f330e70b757a640ba8d4e1eada86445240b5f8cd43194d878e0c05175f6c0
ENV     TF_COREOSBOX_VERSION=v0.0.3
ENV     TF_COREOSBOX_SHA256=88b3b3dd4479748813f9ab30d7fdb9915f303dd5c7b6ae250be5b81e56a9b9c9
ENV     TF_DISTROIMAGE_VERSION=v0.0.1
ENV     TF_DISTROIMAGE_SHA256=df118caec199d650f5aad53051ca1e11f6b054880e9816cc6a5a38f178446ade
ENV     TF_PROVIDEREXECUTE_VERSION=v0.0.4
ENV     TF_PROVIDEREXECUTE_SHA256=c0cdb640e1640210d6bcbda3fa37db0fac8fbd9af39597a765ad7606dd73be7f

ENV     GCLOUD_SDK_VERSION=162.0.0
ENV     GCLOUD_SHA256=4a2fcf7c91830b9a3460dcdb716f37882e2555b8ca22e30b403108e5e4be3158
ENV     GCLOUD_SDK_URL=https://dl.google.com/dl/cloudsdk/channels/rapid/downloads/google-cloud-sdk-${GCLOUD_SDK_VERSION}-linux-x86_64.tar.gz
ENV     CLOUDSDK_PYTHON_SITEPACKAGES 1
# Google cloud kubectl is superseded by downloaded kubectl
ENV     PATH $PATH:/google-cloud-sdk/bin

ENV     ETCD_VERSION=v3.0.17
ENV     ETCD_SHA256=274c46a7f8d26f7ae99d6880610f54933cbcf7f3beafa19236c52eb5df8c7a0b
ENV     ETCDCTL_API=3

ENV     K8S_VERSION=v1.8.4
ENV     K8S_HELM_VERSION=v2.7.2

ENV     K8S_VERSION_1_6=v1.6.13
ENV     K8S_1_6_SHA256=17e29707dcdaac878178d4b137c798cb37993a8a7f0ae214835af4f8e322bafa
ENV     K8S_VERSION_1_7=v1.7.11
ENV     K8S_1_7_SHA256=2885776fa5c80fd8b504e3ac119343c9117c156be68682d0c4e8c7f1b59b88cd
ENV     K8S_VERSION_1_8=v1.8.4
ENV     K8S_1_8_SHA256=fb3cbf25e71f414381e8a6b8a2dc2abb19344feea660ac0445ccf5d43a093f10

ENV     K8S_HELM_VERSION_1_6=v2.5.1
ENV     HELM_2_5_SHA256=0ea53d0d6086805f8f22c609a2f1b5b21ced96d5cf4c6a4a70588bc3822e79c2
ENV     K8S_HELM_VERSION_1_7=v2.6.2
ENV     HELM_2_6_SHA256=ba807d6017b612a0c63c093a954c7d63918d3e324bdba335d67b7948439dbca8
ENV     K8S_HELM_VERSION_1_8=v2.7.2
ENV     HELM_2_7_SHA256=9f04c4824fc751d6c932ae5b93f7336eae06e78315352aa80241066aa1d66c49

ENV     CRASH_APP_SHA256=7f0697cf50a98d87a14be5d4c2d2a31a166df8d7a5eed830a90ead8b49bf3d97

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
        echo "${TF_SHA256}  terraform_${TERRAFORM_VERSION}_linux_amd64.zip" | sha256sum -c - && \
        unzip terraform_${TERRAFORM_VERSION}_linux_amd64.zip && \
        rm terraform_${TERRAFORM_VERSION}_linux_amd64.zip && \
        mv terraform /usr/bin/

# Adding Terraform Provider Execute addon
RUN     wget -q -O tf-prov.tgz https://github.com/samsung-cnct/terraform-provider-execute/releases/download/${TF_PROVIDEREXECUTE_VERSION}/terraform-provider-execute_linux_amd64.tar.gz && \
        echo "${TF_PROVIDEREXECUTE_SHA256}  tf-prov.tgz" | sha256sum -c - && \
        tar -zxvf tf-prov.tgz && \
        rm tf-prov.tgz && \
        mv terraform-provider-execute /usr/bin/

# Adding Terraform CoreOS Box addon
RUN     wget -q -O tf-coreos.tgz https://github.com/samsung-cnct/terraform-provider-coreosbox/releases/download/${TF_COREOSBOX_VERSION}/terraform-provider-coreosbox_linux_amd64.tar.gz && \
        echo "${TF_COREOSBOX_SHA256}  tf-coreos.tgz" | sha256sum -c - && \
        tar -zxvf tf-coreos.tgz && \
        rm tf-coreos.tgz && \
        mv terraform-provider-coreosbox /usr/bin/

# Adding Terraform Distro Image Selector addon
RUN     wget -q -O tf-distroimage.tgz https://github.com/samsung-cnct/terraform-provider-distroimage/releases/download/${TF_DISTROIMAGE_VERSION}/terraform-provider-distroimage_linux_amd64.tar.gz && \
        echo "${TF_DISTROIMAGE_SHA256}  tf-distroimage.tgz" | sha256sum -c - && \
        tar -zxvf tf-distroimage.tgz && \
        rm tf-distroimage.tgz && \
        mv terraform-provider-distro /usr/bin/

# Etcd
RUN     wget -q -O etcd.tgz https://github.com/coreos/etcd/releases/download//${ETCD_VERSION}/etcd-${ETCD_VERSION}-linux-amd64.tar.gz && \
        echo "${ETCD_SHA256}  etcd.tgz" | sha256sum -c - && \
        tar -zxvf etcd.tgz && \
        cp etcd-${ETCD_VERSION}-linux-amd64/etcdctl /usr/local/bin && \
        rm -rf etcd-${ETCD_VERSION}-linux-amd64/ && \
        rm -f etcd.tgz

# Creating path for helm and kubectl executables
RUN     mkdir -p /opt/cnct/kubernetes/v1.6/bin \
                 /opt/cnct/kubernetes/v1.7/bin \
                 /opt/cnct/kubernetes/v1.8/bin \
                 /etc/helm/plugins

# Kubectl
RUN     wget -q https://storage.googleapis.com/kubernetes-release/release/${K8S_VERSION_1_6}/bin/linux/amd64/kubectl && \
        echo "${K8S_1_6_SHA256}  kubectl" | sha256sum -c - && \
        chmod a+x kubectl && \
        mv kubectl /opt/cnct/kubernetes/v1.6/bin
RUN     wget -q https://storage.googleapis.com/kubernetes-release/release/${K8S_VERSION_1_7}/bin/linux/amd64/kubectl && \
        echo "${K8S_1_7_SHA256}  kubectl" | sha256sum -c - && \
        chmod a+x kubectl && \
        mv kubectl /opt/cnct/kubernetes/v1.7/bin
RUN     wget -q https://storage.googleapis.com/kubernetes-release/release/${K8S_VERSION_1_8}/bin/linux/amd64/kubectl && \
        echo "${K8S_1_8_SHA256}  kubectl" | sha256sum -c - && \
        chmod a+x kubectl && \
        mv kubectl /opt/cnct/kubernetes/v1.8/bin


# Helm
RUN     wget -q -O helm-1-6.tgz http://storage.googleapis.com/kubernetes-helm/helm-v2.5.1-linux-amd64.tar.gz  && \
        echo "${HELM_2_5_SHA256}  helm-1-6.tgz" | sha256sum -c - && \
        tar -zxvf helm-1-6.tgz  && \
        mv linux-amd64/helm /opt/cnct/kubernetes/v1.6/bin/helm  && \
        rm -rf linux-amd64 helm-1-6.tgz
RUN     wget -q -O helm-1-7.tgz http://storage.googleapis.com/kubernetes-helm/helm-${K8S_HELM_VERSION_1_7}-linux-amd64.tar.gz  && \
        echo "${HELM_2_6_SHA256}  helm-1-7.tgz" | sha256sum -c - && \
        tar -zxvf helm-1-7.tgz  && \
        mv linux-amd64/helm /opt/cnct/kubernetes/v1.7/bin/helm  && \
        rm -rf linux-amd64 helm-1-7.tgz
RUN     wget -q -O helm-1-8.tgz http://storage.googleapis.com/kubernetes-helm/helm-${K8S_HELM_VERSION_1_8}-linux-amd64.tar.gz  && \
        echo "${HELM_2_7_SHA256}  helm-1-8.tgz" | sha256sum -c - && \
        tar -zxvf helm-1-8.tgz  && \
        mv linux-amd64/helm /opt/cnct/kubernetes/v1.8/bin/helm  && \
        rm -rf linux-amd64 helm-1-8.tgz

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
        echo "${GCLOUD_SHA256}  gcloud.tgz" | sha256sum -c - && \
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
        echo "${CRASH_APP_SHA256}  crash-app.tgz" | sha256sum -c - && \
        tar -zxvf crash-app.tgz  && \
        mv k2-crash-application /usr/bin/k2-crash-application && \
        rm -f crash-app.tgz


# Quick verification script to confirm all expected binaries are present.
ADD tests/internal_tooling.sh /internal_tooling_test.sh
