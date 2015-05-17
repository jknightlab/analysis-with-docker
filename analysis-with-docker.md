---
title: Data Analysis with Docker
author: Peter Humburg
date: 19th May 2015
---

# Introduction
## What is Docker?

* Platform designed for developing, distributing and running applications.
* A Docker image contains an application and all its dependencies.
* Can be run anywhere with minimal setup and configuration.
* Similar to a Virtual Machine but lightweight, more portable and efficient.
* A new Docker image can be based on an existing one, inheriting all its content and functionality.
* Multiple images can be linked to create more complex environments.

## Using Docker

* An application and its dependencies are bundled as a Docker image.
* Docker images are distributed via [DockerHub](https://hub.docker.com/) or other repositories.
* Images are downloaded to host machines (local or in the cloud).
* Running a Docker image produces a Docker container that contains the running application.
* Multiple containers can be created from the same image.

## How is this relevant for data analysis?

* Provides stable environment during analysis
    - Full control over all software versions used for each project/analysis.
    - Independent of host system.
* Helps to make analysis reproducible
    - To ensure an analysis is reproducible we need to communicate all software (including the version used) as well as the code used to carry out the analysis.
    - Docker makes this easy by providing a way to distribute the complete environment used for the analysis.
    - This can include all the software, a script to run the analysis and even the data.

# Building a Docker image for data analysis
## Differential expression / eQTL analysis

* Set up Docker image with support for differential expression and eQTL analysis using R.
* Will show parts of relevant Docker file throughout. Complete file is available [online](https://github.com/jknightlab/heatshock/blob/master/Dockerfile).  

## Choosing a base image

* Docker files are plain text files with instructions on how to build an image.
* Can either build upon an existing image or start from scratch.
* DockerHub provides a large number of images that can serve as a starting point.
* For an analysis that relies mostly on R the [Bioconductor images](https://registry.hub.docker.com/repos/bioconductor/) are a good starting point.
* A minimal Docker file also requires a *maintainer* field.

```docker
FROM bioconductor/release_microarray:latest
MAINTAINER Peter Humburg <peter.humburg@gmail.com>
```

## Installing additional software

* Bioconductor images are based on Debian.
* Can install software using `apt-get` or through other channels.
* Install LaTeX, pandoc and a web server

```docker
RUN apt-get update -y && apt-get install -y haskell-platform nginx lmodern texlive-full libssh-dev  
RUN cabal update && cabal install pandoc
```

## Downloading software

* Software not available through a package management system can be downloaded and installed directly.
* Install *PLINK* by downloading the executable.

```.docker
RUN cd /tmp && wget -q https://www.cog-genomics.org/static/bin/plink150507/plink_linux_x86_64.zip && unzip plink_linux_x86_64.zip && cp plink /usr/local/bin/ 
```

## Install R packages

* Can execute any command in the shell.
* Everything installed by previous commands is available.

```docker
RUN Rscript -e "biocLite(c('sparcl', 'dplyr', 'tidyr', 'devtools', 'illuminaHumanv3.db', 'pander', 'ggdendro'))"
RUN Rscript -e "devtools::install_github('hadley/readr')"
```