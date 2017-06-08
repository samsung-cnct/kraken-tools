# K2 Tools

The recommended K2 Developer Tool, intended to mitigate version issues and requirements,
allowing you the dev to focus on coding and not worry on dependencies.

This is the base layer for the K2 project. Any dependencies or other environment 
work should be done here and let the K2 build focus on installing and 
configuring the code in the K2 repo.

## Sample work flow

Assumptions:
* You have used K2 to generate a config file.
* You have pull the latest image on your machine (keeps you on track with changes upstream)

```
docker pull quay.io/samsung_cnct/k2-tools
```

* You are currently on the your local k2 github fork directory

Steps:
* Generate latest configuration file, as suggested by the K2 repo.
* Create a docker container that access your cluster k2 configs (generated earlier)

```
hack/dockerdev -c <PATH_TO_CONFIGS>/<YOUR_CONFIG>.yaml
```

* After some time, you will be in the bash terminal of the container, bring up your cluster
as you would normally (including any flags you require.):

```
/up.sh -c <PATH_TO_CONFIGS>/<YOUR_CONFIG>.yaml
```

