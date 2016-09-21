FROM alpine:3.4
MAINTAINER Michael Venezia <mvenezia@gmail.com>

ENV     TERRAFORM_VERSION=0.7.3
ENV     TF_COREOSBOX_VERSION=v0.0.2
ENV     TF_PROVIDEREXECUTE_VERSION=v0.0.3

ENV     AWS_CLI53_VERSION=0.8.5

ENV     K8S_VERSION=v1.3.7
ENV     K8S_HELM_VERSION=v2.0.0-alpha.4

# Prepping Alpine

ADD     /alpine-builds /alpine-builds

        # Adding baseline alpine packages
RUN     apk update && apk add openssl python bash py-pip unzip curl zip && \
    	/alpine-builds/build-docker.sh && rm -rf /alpine-builds

# Python / ansible addon work

        # Adding Python packages (awscli and netaddr)
RUN     pip install netaddr

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
RUN     wget https://github.com/barnybug/cli53/releases/download/${AWS_CLI53_VERSION}/cli53-linux-amd64 && \
        chmod a+x cli53-linux-amd64 && mv cli53-linux-amd64 /usr/bin/


# Kubernetes

        # Adding Kubernetes
RUN     curl -O https://storage.googleapis.com/kubernetes-release/release/${K8SVERSION}/bin/linux/amd64/kubectl && chmod a+x kubectl && mv kubectl /usr/bin

        # Adding Helm
RUN     wget https://github.com/kubernetes/helm/releases/download/${K8S_HELM_VERSION}/helm-${K8S_HELM_VERSION}-linux-amd64.tar.gz && \
        tar -zxvf helm-${K8S_HELM_VERSION}-linux-amd64.tar.gz && mv linux-amd64/helm /usr/bin/ && rm -rf linux-amd64 helm-${K8S_HELM_VERSION}-linux-amd64.tar.gz
