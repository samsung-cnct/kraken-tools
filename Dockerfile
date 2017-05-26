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

ENV     GOPATH /go
ENV     GO15VENDOREXPERIMENT 1

# Prepping Alpine

ADD     /alpine-builds /alpine-builds

        # Adding baseline alpine packages
RUN     apk update && apk add --no-cache openssl python bash wget py-pip py-cffi py-cryptography unzip curl zip make go git && \
    	/alpine-builds/build-docker.sh && rm -rf /alpine-builds

# Python / ansible addon work
ADD     requirements.txt /requirements.txt
        # update pip
RUN     pip install --upgrade pip
        # install all python packages
RUN     pip install -r /requirements.txt


### HACK TO WORK AROUND ANSIBLE 2.3.0 BUG
#   remove once updated to 2.3.1
RUN     cd /usr/lib/python2.7/site-packages && curl -o - https://github.com/ansible/ansible/commit/b99f4892d7cef2b91f7376f9255b6614ce2494dc.patch | patch -p2

# Terraform

        #Installing Terraform binary
RUN     curl -O https://releases.hashicorp.com/terraform/${TERRAFORM_VERSION}/terraform_${TERRAFORM_VERSION}_linux_amd64.zip && \
	    unzip terraform_${TERRAFORM_VERSION}_linux_amd64.zip && rm terraform_${TERRAFORM_VERSION}_linux_amd64.zip && mv terraform /usr/bin/

	    # Adding Terraform Provider Execute addon
RUN     wget https://github.com/samsung-cnct/terraform-provider-execute/releases/download/${TF_PROVIDEREXECUTE_VERSION}/terraform-provider-execute_linux_amd64.tar.gz && \
        tar -zxvf terraform-provider-execute_linux_amd64.tar.gz && rm terraform-provider-execute_linux_amd64.tar.gz && mv terraform-provider-execute /usr/bin/

	    # Adding Terraform CoreOS Box addon
RUN 	wget https://github.com/samsung-cnct/terraform-provider-coreosbox/releases/download/${TF_COREOSBOX_VERSION}/terraform-provider-coreosbox_linux_amd64.tar.gz && \
	    tar -zxvf terraform-provider-coreosbox_linux_amd64.tar.gz && rm terraform-provider-coreosbox_linux_amd64.tar.gz && mv terraform-provider-coreosbox /usr/bin/

	    # Adding Terraform Distro Image Selector addon
RUN 	wget https://github.com/samsung-cnct/terraform-provider-distroimage/releases/download/${TF_DISTROIMAGE_VERSION}/terraform-provider-distroimage_linux_amd64.tar.gz && \
	    tar -zxvf terraform-provider-distroimage_linux_amd64.tar.gz && rm terraform-provider-distroimage_linux_amd64.tar.gz && mv terraform-provider-distro /usr/bin/

# AWS work

        # Adding AWS CLI
RUN     pip install awscli

# Google cloud work
RUN     wget https://dl.google.com/dl/cloudsdk/channels/rapid/google-cloud-sdk.zip && \
        unzip google-cloud-sdk.zip && \
        rm google-cloud-sdk.zip
RUN     google-cloud-sdk/install.sh --usage-reporting=false --path-update=false --bash-completion=false


        # Disable updater check for the whole installation.
        # Users won't be bugged with notifications to update to the latest version of gcloud.
RUN     google-cloud-sdk/bin/gcloud config set --installation component_manager/disable_update_check true

        # Disable updater completely.
        # Running `gcloud components update` doesn't really do anything in a union FS.
        # Changes are lost on a subsequent run.
RUN     sed -i -- 's/\"disable_updater\": false/\"disable_updater\": true/g' /google-cloud-sdk/lib/googlecloudsdk/core/config.json


# Kubernetes

        # Adding Kubernetes
RUN     wget https://storage.googleapis.com/kubernetes-release/release/${K8S_VERSION}/bin/linux/amd64/kubectl && chmod a+x kubectl && mv kubectl /usr/bin

        # Adding Helm
RUN     wget http://storage.googleapis.com/kubernetes-helm/helm-${K8S_HELM_VERSION}-linux-amd64.tar.gz && \
        tar -zxvf helm-${K8S_HELM_VERSION}-linux-amd64.tar.gz && mv linux-amd64/helm /usr/bin/ && rm -rf linux-amd64 helm-${K8S_HELM_VERSION}-linux-amd64.tar.gz


        #Helm versioning
RUN     mkdir -p /opt/cnct/kubernetes/v1.4/bin
RUN     mkdir -p /opt/cnct/kubernetes/v1.5/bin
RUN     mkdir -p /opt/cnct/kubernetes/v1.6/bin

RUN     wget http://storage.googleapis.com/kubernetes-helm/helm-${K8S_HELM_VERSION_1_4}-linux-amd64.tar.gz && \
        tar -zxvf helm-${K8S_HELM_VERSION_1_4}-linux-amd64.tar.gz && mv linux-amd64/helm /opt/cnct/kubernetes/v1.4/bin/helm && rm -rf linux-amd64 helm-${K8S_HELM_VERSION_1_4}-linux-amd64.tar.gz
RUN     wget http://storage.googleapis.com/kubernetes-helm/helm-${K8S_HELM_VERSION_1_5}-linux-amd64.tar.gz && \
        tar -zxvf helm-${K8S_HELM_VERSION_1_5}-linux-amd64.tar.gz && mv linux-amd64/helm /opt/cnct/kubernetes/v1.5/bin/helm && rm -rf linux-amd64 helm-${K8S_HELM_VERSION_1_5}-linux-amd64.tar.gz
#RUN     wget http://storage.googleapis.com/kubernetes-helm/helm-${K8S_HELM_VERSION_1_6}-linux-amd64.tar.gz && \
#        tar -zxvf helm-${K8S_HELM_VERSION_1_6}-linux-amd64.tar.gz && mv linux-amd64/helm /opt/cnct/kubernetes/v1.6/bin/helm && rm -rf linux-amd64 helm-${K8S_HELM_VERSION_1_6}-linux-amd64.tar.gz

        # Kubectl versioning
#RUN     mkdir -p /opt/cnct/kubernetes/v1.4/bin
#RUN     mkdir -p /opt/cnct/kubernetes/v1.5/bin
#RUN     mkdir -p /opt/cnct/kubernetes/v1.6/bin

RUN     wget https://storage.googleapis.com/kubernetes-release/release/${K8S_VERSION_1_4}/bin/linux/amd64/kubectl && chmod a+x kubectl && mv kubectl /opt/cnct/kubernetes/v1.4/bin
RUN     wget https://storage.googleapis.com/kubernetes-release/release/${K8S_VERSION_1_5}/bin/linux/amd64/kubectl && chmod a+x kubectl && mv kubectl /opt/cnct/kubernetes/v1.5/bin
RUN     wget https://storage.googleapis.com/kubernetes-release/release/${K8S_VERSION_1_6}/bin/linux/amd64/kubectl && chmod a+x kubectl && mv kubectl /opt/cnct/kubernetes/v1.6/bin
