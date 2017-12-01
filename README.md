[![pipeline status](https://git.cnct.io/common-tools/samsung-cnct_kraken-tools/badges/master/pipeline.svg)](https://git.cnct.io/common-tools/samsung-cnct_kraken-tools/commits/master)

# kraken-tools

kraken-tools conveniently manages all system requirements for [kraken-lib](https://github.com/samsung-cnct/kraken-lib). As the base layer, it contains all necessary and expected dependencies at specific, tested versions for correct and repeatable operations of kraken-lib and [kraken](https://github.com/samsung-cnct/kraken). 

It is best to perform any work on dependencies and other environment issues here and let kraken-lib build focus on installing and configuring the code in the kraken-lib repo.

If you want to use kraken-lib to create a Kubernetes cluster on AWS or GKE for production or development, use kraken-tools to avoid versioning and dependency issues. By running kraken-lib inside a kraken-tools Docker container, your environment will be compliant with kraken-lib's requirements. 

## Prerequisites

[Docker](https://www.docker.com/) must be installed on the machine where you run kraken-tools and your user must have permissions to run it.

## Getting Started

Fork and clone this repo to a local computer and run `docker build .` from the kraken-tools directory to create a Docker container with the dependencies to successfully create your cluster. 

## Contributing
We welcome all types of contributions from the community and and don't require a contributor license agreement. To simplify merging, we prefer pull requests based on a feature branch in your personal fork that's based off the current master of the repo. For more details, please refer to our [kraken-lib Contributing](https://github.com/samsung-cnct/kraken-lib/blob/master/CONTRIBUTING.md) document.

## Additional Resources
Here are some additional resources you might find useful:

* #kraken Slack on [k8s.slack.com](https://k8s.slack.com/)
* [kraken](https://github.com/samsung-cnct/kraken)
* [kraken-lib issue tracker](https://github.com/samsung-cnct/kraken-lib/issues)
* [kraken-tools](https://github.com/samsung-cnct/kraken-tools)

## Maintainer

This document is maintained by Patrick Christopher (@coffeepac) at Samsung SDS.
