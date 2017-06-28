podTemplate(label: 'k2-tools', containers: [
    containerTemplate(name: 'jnlp', image: 'quay.io/samsung_cnct/custom-jnlp:0.1', args: '${computer.jnlpmac} ${computer.name}'),
    // containerTemplate(name: 'k2-tools', image: 'quay.io/samsung_cnct/k2-tools:latest', ttyEnabled: true, command: 'cat', alwaysPullImage: true, resourceRequestMemory: '1Gi', resourceLimitMemory: '1Gi'),
    // containerTemplate(name: 'e2e-tester', image: 'quay.io/samsung_cnct/e2etester:0.2', ttyEnabled: true, command: 'cat', alwaysPullImage: true, resourceRequestMemory: '1Gi', resourceLimitMemory: '1Gi'),
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

            stage('docker build') {
                kubesh 'docker build -t quay.io/samsung_cnct/k2-tools:latest .'
            }

            stage('mount  k2 path on k2-tools container') {
              kubesh 'docker run  --rm -it quay.io/samsung_cnct/k2-tools:latest  "/apk update && apk add git && \
              ~/git clone --branch master --depth 1 https://github.com/samsung-cnct/k2.git /kraken && \
              /kraken/build-scripts/fetch-credentials.sh && \
              /kraken/up.sh --generate cluster/aws/config.yaml && \
              /kraken/build-scripts/update-generated-config.sh cluster/aws/config.yaml ${env.JOB_BASE_NAME}-${env.BUILD_ID} && \
              PWD=`pwd` && ./up.sh --config $PWD/cluster/aws/config.yaml --output $PWD/cluster/aws/ -t dryrun"'
              }

            // only push from master.   assume we are on samsung-cnct fork
            //  ToDo:  check for correct fork
            stage('docker push') {
                if (env.BRANCH_NAME == "master") {
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

def dockerctl(command) {
  ""
}

def customContainer(String name, Closure body) {
  withEnv(["CONTAINER_NAME=$name"]) {
    body()
  }
}

// vi: ft=groovy
