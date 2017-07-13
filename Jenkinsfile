podTemplate(label: 'k2-tools', containers: [
    containerTemplate(name: 'jnlp', image: 'quay.io/samsung_cnct/custom-jnlp:0.1', args: '${computer.jnlpmac} ${computer.name}'),
    containerTemplate(name: 'docker', image: 'docker', command: 'cat', ttyEnabled: true)
  ], volumes: [
    hostPathVolume(hostPath: '/var/run/docker.sock', mountPath: '/var/run/docker.sock'),
    hostPathVolume(hostPath: '/var/lib/docker/scratch', mountPath: '/mnt/scratch'),
    secretVolume(mountPath: '/home/jenkins/.docker/', secretName: 'samsung-cnct-quay-robot-dockercfg')
  ]) {
    node('k2-tools') {
        customContainer('docker') {
            // add a docker rmi/docker purge/etc.
            stage('checkout') {
                checkout scm
            }
            // build new version of k2-tools image on 'docker' container
            stage('docker build') {
                kubesh "docker build -t k2-tools:${env.JOB_BASE_NAME}.${env.BUILD_ID} build"
            }
            
            parallel (
              aws: {
                // test aws (Dryrun, up, down) using k2-tools image
                stage('Run aws tests through k2-tools image') {
                    kubesh "PWD=`pwd` && docker run --rm -i  -e JOB_BASE_NAME=${env.JOB_BASE_NAME} -e BUILD_ID=${env.BUILD_ID} k2-tools:${env.JOB_BASE_NAME}.${env.BUILD_ID} /bin/bash -c tests/aws-testing.sh"
                }
              gke: 
                // test gke (up, down) using k2-tools image
                stage('Run gke tests through k2-tools image') {
                    kubesh "PWD=`pwd` && docker run --rm -i  -e JOB_BASE_NAME=${env.JOB_BASE_NAME} -e BUILD_ID=${env.BUILD_ID} k2-tools:${env.JOB_BASE_NAME}.${env.BUILD_ID} /bin/bash -c tests/gke-testing.sh"
                }
              }
            )

            // only push from master.   assume we are on samsung-cnct fork
            //  ToDo:  check for correct fork
            stage('docker push') {
                if (env.BRANCH_NAME == "master") {
                    kubesh 'docker tag k2-tools:${env.JOB_BASE_NAME}.${env.BUILD_ID} quay.io/samsung_cnct/k2-tools:latest'
                    kubesh 'docker push quay.io/samsung_cnct/k2-tools:latest'
                } else {
                    echo 'not master branch, not pushing to docker repo'
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
