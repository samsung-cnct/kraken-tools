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

ENV     ETCD_VERSION=v3.1.0


ENV     K8S_VERSION=v1.6.7
ENV     K8S_VERSION_OLDEST=v1.4.12
ENV     K8S_VERSION_PRIOR=v1.5.7
ENV     K8S_VERSION_LATEST=v1.6.7

ENV     HELM_VERSION=v2.5.0
ENV     HELM_VERSION_OLDEST=v2.1.3
ENV     HELM_VERSION_PRIOR=v2.3.1
ENV     HELM_VERSION_LATEST=v2.5.0

        #versions of tools
ENV     OLDEST_VERSION_SHORT=v1.4
ENV     PRIOR_VERSION_SHORT=v1.5
ENV     LATEST_VERSION_SHORT=v1.6

ENV     GOPATH /go
ENV     GO15VENDOREXPERIMENT 1

ENV     HELM_HOME=/etc/helm
ENV     HELM_PLUGIN=/etc/helm/plugins

# Prepping Alpine

ADD     /alpine-builds /alpine-builds

        # Adding baseline alpine packages
RUN     apk update && apk add libffi-dev openssl-dev python bash wget py-pip py-cffi py-cryptography unzip zip make git && \
    	/alpine-builds/build-docker.sh && rm -rf /alpine-builds &&  rm -rfv /var/cache/apk/*

# wget
RUN     apk update && apk add ca-certificates wget &&  rm -rfv /var/cache/apk/*

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

# Etcd
RUN     wget https://github.com/coreos/etcd/releases/download//${ETCD_VERSION}/etcd-${ETCD_VERSION}-linux-amd64.tar.gz && \
        tar -zxvf etcd-${ETCD_VERSION}-linux-amd64.tar.gz && \
        cp etcd-${ETCD_VERSION}-linux-amd64/etcdctl /usr/local/bin && \
        rm -rf etcd-${ETCD_VERSION}-linux-amd64/

# Kubernetes
    # Creating path for helm and kubectl executables
RUN     mkdir -p /opt/cnct/kubernetes/${OLDEST_VERSION_SHORT}/bin \
                 /opt/cnct/kubernetes/${PRIOR_VERSION_SHORT}/bin \
                 /opt/cnct/kubernetes/${LATEST_VERSION_SHORT}/bin \
                 /etc/helm/plugins && \
        ln -s /opt/cnct/kubernetes/${LATEST_VERSION_SHORT} /opt/cnct/kubernetes/latest

# Kubectl
RUN     wget https://storage.googleapis.com/kubernetes-release/release/${K8S_VERSION_OLDEST}/bin/linux/amd64/kubectl && \
        chmod a+x kubectl && \
        mv kubectl /opt/cnct/kubernetes/${OLDEST_VERSION_SHORT}/bin
RUN     wget https://storage.googleapis.com/kubernetes-release/release/${K8S_VERSION_PRIOR}/bin/linux/amd64/kubectl && \
        chmod a+x kubectl && \
        mv kubectl /opt/cnct/kubernetes/${PRIOR_VERSION_SHORT}/bin
RUN     wget https://storage.googleapis.com/kubernetes-release/release/${K8S_VERSION_LATEST}/bin/linux/amd64/kubectl && \
        chmod a+x kubectl && \
        mv kubectl /opt/cnct/kubernetes/${LATEST_VERSION_SHORT}/bin && \
        ln -s /opt/cnct/kubernetes/${LATEST_VERSION_SHORT}/bin/kubectl /usr/bin/

# Helm
RUN     wget http://storage.googleapis.com/kubernetes-helm/helm-${HELM_VERSION_OLDEST}-linux-amd64.tar.gz  && \
        tar -zxvf helm-${HELM_VERSION_OLDEST}-linux-amd64.tar.gz  && \
        mv linux-amd64/helm /opt/cnct/kubernetes/${OLDEST_VERSION_SHORT}/bin/helm  && \
        rm -rf linux-amd64 helm-${HELM_VERSION_OLDEST}-linux-amd64.tar.gz
RUN     wget http://storage.googleapis.com/kubernetes-helm/helm-${HELM_VERSION_PRIOR}-linux-amd64.tar.gz  && \
        tar -zxvf helm-${HELM_VERSION_PRIOR}-linux-amd64.tar.gz  && \
        mv linux-amd64/helm /opt/cnct/kubernetes/${PRIOR_VERSION_SHORT}/bin/helm  && \
        rm -rf linux-amd64 helm-${HELM_VERSION_PRIOR}-linux-amd64.tar.gz
RUN     wget http://storage.googleapis.com/kubernetes-helm/helm-${HELM_VERSION_LATEST}-linux-amd64.tar.gz  && \
        tar -zxvf helm-${HELM_VERSION_LATEST}-linux-amd64.tar.gz  && \
        mv linux-amd64/helm /opt/cnct/kubernetes/${LATEST_VERSION_SHORT}/bin/helm  && \
        rm -rf linux-amd64 helm-${HELM_VERSION_LATEST}-linux-amd64.tar.gz && \
        ln -s /opt/cnct/kubernetes/${LATEST_VERSION_SHORT}/bin/helm /usr/bin/

# Python / ansible addon work
ADD     requirements.txt /requirements.txt
ADD     imagerun.sh /imagerun.sh
ADD     gcloud_tree.py /gcloud_tree.py
ADD     k2dryrun.sh /k2dryrun.sh

RUN     /imagerun.sh
RUN     appr plugins install helm && rm /etc/helm/plugins/*.gz

# Crash application
RUN     wget https://github.com/samsung-cnct/k2-crash-application/releases/download/0.1.0/k2-crash-application_0.1.0_linux_amd64.tar.gz  && \
        tar -zxvf k2-crash-application_0.1.0_linux_amd64.tar.gz  && \
        mv k2-crash-application /usr/bin/k2-crash-application && \
        rm -rf k2-crash-application_0.1.0_linux_amd64.tar.gz
