FROM alpine:3.4
ENV K8SVERSION=v1.3.7
ENV TERRAFORMVERSION=0.7.3
ENV CLI53VERSION=0.8.5

ADD	/alpine-builds /alpine-builds

RUN 	apk update && \
	apk add openssl python bash py-pip unzip curl && \
	curl -O https://storage.googleapis.com/kubernetes-release/release/${K8SVERSION}/bin/darwin/amd64/kubectl && chmod a+x kubectl && mv kubectl /usr/bin && \
	curl -O https://releases.hashicorp.com/terraform/${TERRAFORMVERSION}/terraform_${TERRAFORMVERSION}_linux_amd64.zip && \
	unzip terraform_${TERRAFORMVERSION}_linux_amd64.zip && rm terraform_${TERRAFORMVERSION}_linux_amd64.zip && mv terraform /usr/bin/ && \
	pip install awscli && apk del py-pip && \
	wget https://github.com/barnybug/cli53/releases/download/${CLI53VERSION}/cli53-linux-amd64 && \
	chmod a+x cli53-linux-amd64 && mv cli53-linux-amd64 /usr/bin && \
	/alpine-builds/build-docker.sh && rm -rf /alpine-builds


