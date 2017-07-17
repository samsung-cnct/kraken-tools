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

ENV     K8S_VERSION=v1.6.7
ENV     K8S_HELM_VERSION=v2.5.0

ENV     K8S_VERSION_1_4=v1.4.12
ENV     K8S_VERSION_1_5=v1.5.7
ENV     K8S_VERSION_1_6=v1.6.7

ENV     K8S_HELM_VERSION_1_4=v2.1.3
ENV     K8S_HELM_VERSION_1_5=v2.3.1
ENV     K8S_HELM_VERSION_1_6=v2.5.0

#Latest version of tools
ENV     LATEST=v1.6
ENV     K8S_VERSION_LATEST=$K8S_VERSION_1_6
ENV     K8S_HELM_VERSION_LATEST=$K8S_HELM_VERSION_1_6

ENV     GOPATH /go
ENV     GO15VENDOREXPERIMENT 1

ENV     HELM_HOME=/etc/helm
ENV     HELM_PLUGIN=/etc/helm/plugins

# Prepping Alpine

ADD     build/alpine-builds /alpine-builds

        # Adding baseline alpine packages
RUN     apk update && apk add bash ca-certificates g++ gcc git libffi-dev linux-headers make musl-dev openssl openssl-dev python python-dev py-cryptography py-cffi py-pip unzip wget zip  && \
    	/alpine-builds/build-docker.sh && rm -rf /alpine-builds && rm -rfv /var/cache/apk/*

# Terraform

        #Installing Terraform binary
RUN     wget https://releases.hashicorp.com/terraform/${TERRAFORM_VERSION}/terraform_${TERRAFORM_VERSION}_linux_amd64.zip && \
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

# Etcd
RUN     wget https://github.com/coreos/etcd/releases/download//${ETCD_VERSION}/etcd-${ETCD_VERSION}-linux-amd64.tar.gz && \
        tar -zxvf etcd-${ETCD_VERSION}-linux-amd64.tar.gz && \
        cp etcd-${ETCD_VERSION}-linux-amd64/etcdctl /usr/local/bin && \
        rm -rf etcd-${ETCD_VERSION}-linux-amd64/

# Kubernetes
    # Creating path for helm and kubectl executables
RUN     mkdir -p /opt/cnct/kubernetes/v1.4/bin \
                 /opt/cnct/kubernetes/v1.5/bin \
                 /opt/cnct/kubernetes/v1.6/bin \
                 /etc/helm/plugins && \
        ln -s /opt/cnct/kubernetes/${LATEST} /opt/cnct/kubernetes/latest

# Kubectl
RUN     wget https://storage.googleapis.com/kubernetes-release/release/${K8S_VERSION_1_4}/bin/linux/amd64/kubectl && \
        chmod a+x kubectl && \
        mv kubectl /opt/cnct/kubernetes/v1.4/bin
RUN     wget https://storage.googleapis.com/kubernetes-release/release/${K8S_VERSION_1_5}/bin/linux/amd64/kubectl && \
        chmod a+x kubectl && \
        mv kubectl /opt/cnct/kubernetes/v1.5/bin
RUN     wget https://storage.googleapis.com/kubernetes-release/release/${K8S_VERSION_1_6}/bin/linux/amd64/kubectl && \
        chmod a+x kubectl && \
        mv kubectl /opt/cnct/kubernetes/v1.6/bin && \
        ln -s /opt/cnct/kubernetes/${LATEST}/bin/kubectl /usr/bin/

# Helm
RUN     wget http://storage.googleapis.com/kubernetes-helm/helm-${K8S_HELM_VERSION_1_4}-linux-amd64.tar.gz  && \
        tar -zxvf helm-${K8S_HELM_VERSION_1_4}-linux-amd64.tar.gz  && \
        mv linux-amd64/helm /opt/cnct/kubernetes/v1.4/bin/helm  && \
        rm -rf linux-amd64 helm-${K8S_HELM_VERSION_1_4}-linux-amd64.tar.gz
RUN     wget http://storage.googleapis.com/kubernetes-helm/helm-${K8S_HELM_VERSION_1_5}-linux-amd64.tar.gz  && \
        tar -zxvf helm-${K8S_HELM_VERSION_1_5}-linux-amd64.tar.gz  && \
        mv linux-amd64/helm /opt/cnct/kubernetes/v1.5/bin/helm  && \
        rm -rf linux-amd64 helm-${K8S_HELM_VERSION_1_5}-linux-amd64.tar.gz
RUN     wget http://storage.googleapis.com/kubernetes-helm/helm-${K8S_HELM_VERSION_1_6}-linux-amd64.tar.gz  && \
        tar -zxvf helm-${K8S_HELM_VERSION_1_6}-linux-amd64.tar.gz  && \
        mv linux-amd64/helm /opt/cnct/kubernetes/v1.6/bin/helm  && \
        rm -rf linux-amd64 helm-${K8S_HELM_VERSION_1_6}-linux-amd64.tar.gz && \
        ln -s /opt/cnct/kubernetes/${LATEST}/bin/helm /usr/bin/

# Python / ansible addon work
ADD     build/requirements.txt /requirements.txt
ADD     build/gcloud_tree.py /gcloud_tree.py
ADD     tests/aws-testing.sh /aws-testing.sh
ADD     tests/gke-testing.sh /gke-testing.sh

# Install things that need compilers, etc
RUN     pip install -r /requirements.txt

# Google cloud work (copied from https://github.com/GoogleCloudPlatform/cloud-sdk-docker/blob/master/alpine/Dockerfile )
RUN wget ${GCLOUD_SDK_URL} && \
    tar xzf ${GCLOUD_FILE_NAME} && \
    rm ${GCLOUD_FILE_NAME} && \
    ln -s /lib /lib64 && \
    gcloud config set core/disable_usage_reporting true && \
    gcloud config set component_manager/disable_update_check true && \
    gcloud config set metrics/environment github_docker_image

# Install the help app registry plugin
RUN     appr plugins install helm && rm /etc/helm/plugins/*.gz

# Crash application
RUN     wget https://github.com/samsung-cnct/k2-crash-application/releases/download/0.1.0/k2-crash-application_0.1.0_linux_amd64.tar.gz  && \
        tar -zxvf k2-crash-application_0.1.0_linux_amd64.tar.gz  && \
        mv k2-crash-application /usr/bin/k2-crash-application && \
        rm -rf k2-crash-application_0.1.0_linux_amd64.tar.gz
