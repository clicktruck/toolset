# Toolset Container Image

![Current State](https://img.shields.io/badge/current%20state-incubating-lightblue)

An Ubuntu 22.04-based Docker image of curated tools for use with Kubernetes environments.

## Prerequistes

* [Docker](https://docs.docker.com/desktop/) or [nerdctl](https://github.com/containerd/nerdctl)

> Notice: if using Docker a [subscription](https://www.docker.com/blog/updating-product-subscriptions/) is required for business use.


## Building

If you want to build a portable container image, then execute

```
./scripts/build.sh
```
> You may add `docker` or `nerdctl` as an argument to script execution in order to dictate which container build engine is employed to build the image.  If no argument is supplied, the script employs Docker.

## Launching

Execute

```
docker run --rm -it clicktruck/toolset:latest /bin/bash
```

or

```
nerdctl container run --rm -it clicktruck/toolset:latest /bin/bash
```
