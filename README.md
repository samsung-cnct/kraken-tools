# kraken Tools

This is the base layer for the [kraken-lib](https://github.com/samsung-cnct/k2) project. kraken-tools contains all necessary and expected dependencies at specific, tested versions for correct and repeatable operations of kraken-lib and [kraken](https://github.com/samsung-cnct/k2cli).
Any dependencies or other environment 
work should be done here and let the kraken-lib build focus on installing and configuring the code in the kraken-lib repo.

If you want to use kraken-lib to spin up a Kubernetes cluster on AWS or GKE for production or development, kraken-tools lets you avoid versioning and dependency issues. By running kraken-lib inside a kraken-tools Docker container, your environment will be compliant with kraken-libs's requirements. 

## Getting Started

Fork and clone this repo to local computer and run `docker build .` from the kraken-tools directory to create a Docker container with the dependencies to successfully spin up a K2 cluster. 

### Prerequisites

You will need [Docker](https://www.docker.com/) on your local computer to build this image. 

## Contributing

1. Fork it!
2. Create your feature branch: `git checkout -b my-new-feature`
3. Commit your changes: `git commit -am 'Add some feature'`
4. Push to the branch: `git push origin my-new-feature`
5. Submit a pull request :D

## License

This project is licensed under the Apache License 2.0 - see the [LICENSE](https://github.com/samsung-cnct/k2-tools/blob/master/LICENSE) file for details