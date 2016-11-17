FROM alpine:3.4
MAINTAINER Michael Venezia <mvenezia@gmail.com>

ENV     TERRAFORM_VERSION=0.7.11
ENV     TF_COREOSBOX_VERSION=v0.0.2
ENV     TF_PROVIDEREXECUTE_VERSION=v0.0.3

ENV     GCLOUD_SDK_VERSION=128.0.0
ENV     GCLOUD_SDK_URL=https://dl.google.com/dl/cloudsdk/channels/rapid/downloads/google-cloud-sdk-${GCLOUD_SDK_VERSION}-linux-x86_64.tar.gz
ENV     CLOUDSDK_PYTHON_SITEPACKAGES 1
        # google cloud kubectl is superceeded by downloaded kubectl
ENV     PATH $PATH:/google-cloud-sdk/bin

ENV     K8S_VERSION=v1.4.4
ENV     K8S_HELM_VERSION=v2.0.0

ENV     GOPATH /go
ENV     GO15VENDOREXPERIMENT 1

# Prepping Alpine

ADD     /alpine-builds /alpine-builds

        # Adding baseline alpine packages
RUN     apk update && apk add --no-cache openssl python bash wget py-pip py-cffi py-cryptography unzip curl zip make go git && \
    	/alpine-builds/build-docker.sh && rm -rf /alpine-builds

# Python / ansible addon work
        # update pip
RUN     pip install --upgrade pip
        # Adding netaddr
RUN     pip install netaddr boto

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

# AWS work

        # Adding AWS CLI
RUN     pip install awscli

        # Adding cli53
RUN     go get github.com/barnybug/cli53 && cd $GOPATH/src/github.com/barnybug/cli53 && make install && \
        rm -Rf $GOPATH/src && mv $GOPATH/bin/cli53 /usr/bin/cli53

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