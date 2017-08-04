FROM alpine:3.6
MAINTAINER Michael Venezia <mvenezia@gmail.com>

ENV     TERRAFORM_VERSION=0.8.6
ENV     TF_COREOSBOX_VERSION=v0.0.3
ENV     TF_DISTROIMAGE_VERSION=v0.0.1
ENV     TF_PROVIDEREXECUTE_VERSION=v0.0.4

ENV     GCLOUD_SDK_VERSION=162.0.0
ENV     GCLOUD_FILE_NAME=google-cloud-sdk-${GCLOUD_SDK_VERSION}-linux-x86_64.tar.gz
ENV     GCLOUD_SDK_URL=https://dl.google.com/dl/cloudsdk/channels/rapid/downloads/${GCLOUD_FILE_NAME}
ENV     CLOUDSDK_PYTHON_SITEPACKAGES 1
# google cloud kubectl is superceeded by downloaded kubectl
ENV     PATH $PATH:/google-cloud-sdk/bin

ENV     ETCD_VERSION=v3.1.0
ENV     ETCDCTL_API=3

ENV     K8S_VERSION=v1.7.1
ENV     K8S_HELM_VERSION=v2.5.1

ENV     K8S_VERSION_1_5=v1.5.7
ENV     K8S_VERSION_1_6=v1.6.7
ENV     K8S_VERSION_1_7=v1.7.1


ENV     K8S_HELM_VERSION_1_5=v2.3.1
ENV     K8S_HELM_VERSION_1_6=v2.5.0
ENV     K8S_HELM_VERSION_1_7=v2.5.1

#Latest version of tools
ENV     LATEST=v1.7
ENV     K8S_VERSION_LATEST=$K8S_VERSION_1_7
ENV     K8S_HELM_VERSION_LATEST=$K8S_HELM_VERSION_1_7

ENV     GOPATH /go
ENV     GO15VENDOREXPERIMENT 1

ENV     HELM_HOME=/etc/helm
ENV     HELM_PLUGIN=/etc/helm/plugins

# Alpine

ADD     build/alpine-builds /alpine-builds

ENV     APK_PACKAGES="bash ca-certificates openssl openssh python py-pip py-cryptography py-cffi zip unzip wget util-linux"
ENV     APK_DEV_PACKAGES="gcc g++ git make libffi-dev linux-headers musl-dev libc-dev openssl-dev python-dev unzip mkinitfs kmod mtools squashfs-tools"

RUN     apk add --update --no-cache ${APK_PACKAGES} ${APK_DEV_PACKAGES} && \
    	/alpine-builds/build-docker.sh && \
        rm -rf /alpine-builds 

# Terraform
RUN     wget -q https://releases.hashicorp.com/terraform/${TERRAFORM_VERSION}/terraform_${TERRAFORM_VERSION}_linux_amd64.zip && \
        unzip terraform_${TERRAFORM_VERSION}_linux_amd64.zip && \
        rm terraform_${TERRAFORM_VERSION}_linux_amd64.zip && \
        mv terraform /usr/bin/

# Adding Terraform Provider Execute addon
RUN     wget -q https://github.com/samsung-cnct/terraform-provider-execute/releases/download/${TF_PROVIDEREXECUTE_VERSION}/terraform-provider-execute_linux_amd64.tar.gz && \
        tar -zxvf terraform-provider-execute_linux_amd64.tar.gz && \
        rm terraform-provider-execute_linux_amd64.tar.gz && \
        mv terraform-provider-execute /usr/bin/

# Adding Terraform CoreOS Box addon
RUN 	wget -q https://github.com/samsung-cnct/terraform-provider-coreosbox/releases/download/${TF_COREOSBOX_VERSION}/terraform-provider-coreosbox_linux_amd64.tar.gz && \
        tar -zxvf terraform-provider-coreosbox_linux_amd64.tar.gz && \
        rm terraform-provider-coreosbox_linux_amd64.tar.gz && \
        mv terraform-provider-coreosbox /usr/bin/

# Adding Terraform Distro Image Selector addon
RUN 	wget -q https://github.com/samsung-cnct/terraform-provider-distroimage/releases/download/${TF_DISTROIMAGE_VERSION}/terraform-provider-distroimage_linux_amd64.tar.gz && \
        tar -zxvf terraform-provider-distroimage_linux_amd64.tar.gz && \
        rm terraform-provider-distroimage_linux_amd64.tar.gz && \
        mv terraform-provider-distro /usr/bin/

# Etcd
RUN     wget -q https://github.com/coreos/etcd/releases/download//${ETCD_VERSION}/etcd-${ETCD_VERSION}-linux-amd64.tar.gz && \
        tar -zxvf etcd-${ETCD_VERSION}-linux-amd64.tar.gz && \
        cp etcd-${ETCD_VERSION}-linux-amd64/etcdctl /usr/local/bin && \
        rm -rf etcd-${ETCD_VERSION}-linux-amd64/

# Creating path for helm and kubectl executables
RUN     mkdir -p /opt/cnct/kubernetes/v1.7/bin \
                 /opt/cnct/kubernetes/v1.5/bin \
                 /opt/cnct/kubernetes/v1.6/bin \
                 /etc/helm/plugins

# Kubectl
RUN     wget -q https://storage.googleapis.com/kubernetes-release/release/${K8S_VERSION_1_5}/bin/linux/amd64/kubectl && \
        chmod a+x kubectl && \
        mv kubectl /opt/cnct/kubernetes/v1.5/bin
RUN     wget -q https://storage.googleapis.com/kubernetes-release/release/${K8S_VERSION_1_6}/bin/linux/amd64/kubectl && \
        chmod a+x kubectl && \
        mv kubectl /opt/cnct/kubernetes/v1.6/bin
RUN     wget -q https://storage.googleapis.com/kubernetes-release/release/${K8S_VERSION_1_7}/bin/linux/amd64/kubectl && \
        chmod a+x kubectl && \
        mv kubectl /opt/cnct/kubernetes/v1.7/bin
       

# Helm
RUN     wget -q http://storage.googleapis.com/kubernetes-helm/helm-${K8S_HELM_VERSION_1_5}-linux-amd64.tar.gz  && \
        tar -zxvf helm-${K8S_HELM_VERSION_1_5}-linux-amd64.tar.gz  && \
        mv linux-amd64/helm /opt/cnct/kubernetes/v1.5/bin/helm  && \
        rm -rf linux-amd64 helm-${K8S_HELM_VERSION_1_5}-linux-amd64.tar.gz
RUN     wget -q http://storage.googleapis.com/kubernetes-helm/helm-${K8S_HELM_VERSION_1_6}-linux-amd64.tar.gz  && \
        tar -zxvf helm-${K8S_HELM_VERSION_1_6}-linux-amd64.tar.gz  && \
        mv linux-amd64/helm /opt/cnct/kubernetes/v1.6/bin/helm  && \
        rm -rf linux-amd64 helm-${K8S_HELM_VERSION_1_6}-linux-amd64.tar.gz
RUN     wget -q http://storage.googleapis.com/kubernetes-helm/helm-${K8S_HELM_VERSION_1_7}-linux-amd64.tar.gz  && \
        tar -zxvf helm-${K8S_HELM_VERSION_1_7}-linux-amd64.tar.gz  && \
        mv linux-amd64/helm /opt/cnct/kubernetes/v1.7/bin/helm  && \
        rm -rf linux-amd64 helm-${K8S_HELM_VERSION_1_7}-linux-amd64.tar.gz

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
RUN     wget -q ${GCLOUD_SDK_URL} && \
        tar xzf ${GCLOUD_FILE_NAME} && \
        rm ${GCLOUD_FILE_NAME} && \
        ln -s /lib /lib64 && \
        gcloud config set core/disable_usage_reporting true && \
        gcloud config set component_manager/disable_update_check true && \
        gcloud config set metrics/environment github_docker_image

# Install the help app registry plugin
RUN     appr plugins install helm && rm /etc/helm/plugins/*.gz

# Crash application
RUN     wget -q https://github.com/samsung-cnct/k2-crash-application/releases/download/0.1.0/k2-crash-application_0.1.0_linux_amd64.tar.gz && \
        tar -zxvf k2-crash-application_0.1.0_linux_amd64.tar.gz  && \
        mv k2-crash-application /usr/bin/k2-crash-application && \
        rm -f k2-crash-application_0.1.0_linux_amd64.tar.gz


# Quick verification script to confirm all expected binaries are present.
ADD tests/internal_tooling.sh /internal_tooling_test.sh


