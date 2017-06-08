#!/bin/sh -e
set -o pipefail

# Prepping Alpine
# Adding baseline alpine packages
apk update 
apk add --no-cache  \
    openssl \
    ca-certificates \
    python \
    bash \
    wget \
    py-pip \
    py-cffi \
    py-cryptography \
    unzip \
    zip \
    python-dev \
    gcc \
    linux-headers \
    musl-dev \
    g++
/alpine-builds/build-docker.sh 
rm -rf /alpine-builds

# Python / ansible addon work
# update pip
pip install --upgrade pip
# install all python packages
pip install -r /requirements.txt

# Terraform
#Installing Terraform binary
wget https://releases.hashicorp.com/terraform/${TERRAFORM_VERSION}/terraform_${TERRAFORM_VERSION}_linux_amd64.zip 
    unzip terraform_${TERRAFORM_VERSION}_linux_amd64.zip 
rm terraform_${TERRAFORM_VERSION}_linux_amd64.zip 
mv terraform /usr/bin/
# Adding Terraform Provider Execute addon
wget https://github.com/samsung-cnct/terraform-provider-execute/releases/download/${TF_PROVIDEREXECUTE_VERSION}/terraform-provider-execute_linux_amd64.tar.gz 
    tar -zxvf terraform-provider-execute_linux_amd64.tar.gz 
rm terraform-provider-execute_linux_amd64.tar.gz 
mv terraform-provider-execute /usr/bin/
# Adding Terraform CoreOS Box addon
wget https://github.com/samsung-cnct/terraform-provider-coreosbox/releases/download/${TF_COREOSBOX_VERSION}/terraform-provider-coreosbox_linux_amd64.tar.gz 
    tar -zxvf terraform-provider-coreosbox_linux_amd64.tar.gz 
rm terraform-provider-coreosbox_linux_amd64.tar.gz 
mv terraform-provider-coreosbox /usr/bin/
# Adding Terraform Distro Image Selector addon
wget https://github.com/samsung-cnct/terraform-provider-distroimage/releases/download/${TF_DISTROIMAGE_VERSION}/terraform-provider-distroimage_linux_amd64.tar.gz 
    tar -zxvf terraform-provider-distroimage_linux_amd64.tar.gz 
rm terraform-provider-distroimage_linux_amd64.tar.gz 
mv terraform-provider-distro /usr/bin/

# Kubernetes
# Creating path for helm and kubectl executables
mkdir -p /opt/cnct/kubernetes/v1.4/bin /opt/cnct/kubernetes/v1.5/bin /opt/cnct/kubernetes/v1.6/bin
ln -s /opt/cnct/kubernetes/$LATEST /opt/cnct/kubernetes/latest

# Kubectl
wget https://storage.googleapis.com/kubernetes-release/release/${K8S_VERSION_1_4}/bin/linux/amd64/kubectl 
chmod a+x kubectl 
mv kubectl /opt/cnct/kubernetes/v1.4/bin
wget https://storage.googleapis.com/kubernetes-release/release/${K8S_VERSION_1_5}/bin/linux/amd64/kubectl 
chmod a+x kubectl 
mv kubectl /opt/cnct/kubernetes/v1.5/bin
wget https://storage.googleapis.com/kubernetes-release/release/${K8S_VERSION_1_6}/bin/linux/amd64/kubectl 
chmod a+x kubectl 
mv kubectl /opt/cnct/kubernetes/v1.6/bin
ln -s /opt/cnct/kubernetes/v1.4/bin/kubectl /usr/bin/

# Helm
wget http://storage.googleapis.com/kubernetes-helm/helm-${K8S_HELM_VERSION_1_4}-linux-amd64.tar.gz 
tar -zxvf helm-${K8S_HELM_VERSION_1_4}-linux-amd64.tar.gz 
mv linux-amd64/helm /opt/cnct/kubernetes/v1.4/bin/helm 
rm -rf linux-amd64 helm-${K8S_HELM_VERSION_1_4}-linux-amd64.tar.gz
wget http://storage.googleapis.com/kubernetes-helm/helm-${K8S_HELM_VERSION_1_5}-linux-amd64.tar.gz 
tar -zxvf helm-${K8S_HELM_VERSION_1_5}-linux-amd64.tar.gz 
mv linux-amd64/helm /opt/cnct/kubernetes/v1.5/bin/helm 
rm -rf linux-amd64 helm-${K8S_HELM_VERSION_1_5}-linux-amd64.tar.gz
wget http://storage.googleapis.com/kubernetes-helm/helm-${K8S_HELM_VERSION_1_6}-linux-amd64.tar.gz 
tar -zxvf helm-${K8S_HELM_VERSION_1_6}-linux-amd64.tar.gz 
mv linux-amd64/helm /opt/cnct/kubernetes/v1.6/bin/helm 
rm -rf linux-amd64 helm-${K8S_HELM_VERSION_1_6}-linux-amd64.tar.gz
ln -s /opt/cnct/kubernetes/v1.5/bin/helm /usr/bin/

# Clean up unneeded data
apk del alpine-sdk mtools mkinitfs kmod squashfs-tools git g++ gcc make musl-dev libc-dev python-dev linux-headers
rm -rfv ~/.cache
rm -rfv /var/cache/apk/*
