// Configuration variables
github_org             = "samsung-cnct"
quay_org               = "samsung_cnct"
publish_branch         = "master"
image_tag              = "${env.RELEASE_VERSION}" != "null" ? "${env.RELEASE_VERSION}" : "latest"

podTemplate(label: 'kraken-tools', containers: [
    containerTemplate(name: 'jnlp', image: "quay.io/${quay_org}/custom-jnlp:0.1", args: '${computer.jnlpmac} ${computer.name}'),
    containerTemplate(name: 'docker', image: 'docker', command: 'cat', ttyEnabled: true)
  ], volumes: [
    hostPathVolume(hostPath: '/var/run/docker.sock', mountPath: '/var/run/docker.sock'),
    hostPathVolume(hostPath: '/var/lib/docker/scratch', mountPath: '/mnt/scratch'),
    secretVolume(mountPath: '/home/jenkins/.docker/', secretName: 'samsung-cnct-quay-robot-dockercfg')
  ]) {
    node('kraken-tools') {
        customContainer('docker') {
            // add a docker rmi/docker purge/etc.
            stage('Checkout') {
                checkout scm
                // retrieve the URI used for checking out the source
                // this assumes one branch with one uri
                git_uri = scm.getRepositories()[0].getURIs()[0].toString()
                git_branch = scm.getBranches()[0].toString()
            }
            // build new version of kraken-tools image on 'docker' container
            stage('Build') {
                kubesh "docker build -t kraken-tools:${env.JOB_BASE_NAME}.${env.BUILD_ID} ."
            }
            
            stage('Test') {
                parallel (
                    "aws": {
                        // test aws (Dryrun, up, down) using kraken-tools image
                        kubesh "PWD=`pwd` && docker run --rm -i  -e JOB_BASE_NAME=${env.JOB_BASE_NAME} -e BUILD_ID=${env.BUILD_ID} kraken-tools:${env.JOB_BASE_NAME}.${env.BUILD_ID} /bin/bash -c /aws-testing.sh"
                    },
                    "gke": {
                    // test gke (up, down) using kraken-tools image
                    kubesh "PWD=`pwd` && docker run --rm -i  -e JOB_BASE_NAME=${env.JOB_BASE_NAME} -e BUILD_ID=${env.BUILD_ID} kraken-tools:${env.JOB_BASE_NAME}.${env.BUILD_ID} /bin/bash -c /gke-testing.sh"
                    }
                )
            }
            
            // only push from master.   check that we are on samsung-cnct fork
            stage('Publish') {
              if (git_branch.contains(publish_branch) && git_uri.contains(github_org)) {
                kubesh "docker tag kraken-tools:${env.JOB_BASE_NAME}.${env.BUILD_ID} quay.io/${quay_org}/k2-tools:${image_tag}"
                kubesh "docker tag kraken-tools:${env.JOB_BASE_NAME}.${env.BUILD_ID} quay.io/${quay_org}/k2-tools:latest"
                kubesh "docker tag kraken-tools:${env.JOB_BASE_NAME}.${env.BUILD_ID} quay.io/${quay_org}/kraken-tools:${image_tag}"
                kubesh "docker tag kraken-tools:${env.JOB_BASE_NAME}.${env.BUILD_ID} quay.io/${quay_org}/kraken-tools:latest"
                kubesh "docker push quay.io/${quay_org}/k2-tools:${image_tag}"
                kubesh "docker push quay.io/${quay_org}/k2-tools:latest"
                kubesh "docker push quay.io/${quay_org}/kraken-tools:${image_tag}"
                kubesh "docker push quay.io/${quay_org}/kraken-tools:latest"
              } else {
                echo "Not pushing to docker repo:\n    BRANCH_NAME='${env.BRANCH_NAME}'\n    GIT_BRANCH='${git_branch}'\n    git_uri='${git_uri}'"
              }
            }
        }

    }
  }

def kubesh(command) {
  if (env.CONTAINER_NAME) {
    if ((command instanceof String) || (command instanceof GString)) {
      command = kubectl(command)
    }

    if (command instanceof LinkedHashMap) {
      command["script"] = kubectl(command["script"])
    }
  }
  sh(command)
}

def kubectl(command) {
  "kubectl exec -i ${env.HOSTNAME} -c ${env.CONTAINER_NAME} -- /bin/sh -c 'cd ${env.WORKSPACE} && ${command}'"
}

def customContainer(String name, Closure body) {
  withEnv(["CONTAINER_NAME=$name"]) {
    body()
  }
}

// vi: ft=groovy
