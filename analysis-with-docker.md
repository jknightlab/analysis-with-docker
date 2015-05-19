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

## What is Docker? (cont.) {.small-header}
* Similar to a Virtual Machine but lightweight, more portable and efficient.
* A new Docker image can be based on an existing one, inheriting all its content and functionality.
* Multiple images can be linked to create more complex environments.

## Using Docker

* An application and its dependencies are bundled as a Docker image.
* Docker images are distributed via [DockerHub](https://hub.docker.com/) or other repositories.
* Images are downloaded to host machines (local or in the cloud).
* Running a Docker image produces a Docker container that contains the running application.
* Multiple containers can be created from the same image.

## How is this relevant for data analysis? {.small-header}

* Provides stable environment during analysis
    - Full control over all software versions used.
    - Independent of host system.
* Helps to make analysis reproducible
    - Docker provides a way to distribute the complete environment used for the analysis.
    - This can include all the software, a script to run the analysis and even the data.

# Building a Docker image for data analysis
## Differential expression / eQTL analysis {.small-header}

Want to create an image that

* runs a specified analysis on start-up
* generates a report and serves it as a web page (including pdf download)$^*$
* provides interactive access to allow further investigation 
 
<div class="footnote">
$^*$ Using techniques described [here](http://galahad.well.ox.ac.uk/repro/)
</div>

## Example

* Set up Docker image with support for differential expression and eQTL analysis using R.
* Will show parts of relevant Docker file throughout. Complete file is available 
  [online](https://github.com/jknightlab/heatshock/blob/master/Dockerfile).  


## Dockerfile

* A Dockerfile is a plain test file that contains a series of instructions to 
  build a Docker image.
* Can use an existing image as base.
* Lists instructions to
	- install additional software
	- configure the software inside the image
	- copy files
	- ...

## Choosing a base image {.small-header}

* Can either build upon an existing image or start from scratch.
* DockerHub provides a large number of images that can serve as a starting point.
* For an analysis that relies mostly on R the [Bioconductor images](https://registry.hub.docker.com/repos/bioconductor/) are a good starting point.
* A minimal Docker file also requires a *maintainer* field.

```docker
FROM bioconductor/release_microarray:latest
MAINTAINER Peter Humburg <peter.humburg@gmail.com>
```

## The Bioconductor images {.small-header}

* Bioconductor provides a series of images with different collections of Biocoductor
  packages installed.
* The *base* image contains R, RStudio and the BiocInstaller package.
* The *core* image contains the *base* image and basic BioC infrastructure.
* Application specific images build on *core*: *flow*, *microarray*,
  *proteomics*, *sequencing*.
* All images are available for the development and release versions of Bioconductor.

## Customising the image {.small-header}

* Install LaTeX, pandoc and a web server.
* Add analysis code.
* Configure the image to run the analysis and provide access to HTML and
  PDF versions of resulting report.

## Downloading software {.small-header}

* Can install software using `apt-get` or through other channels.

```docker
RUN apt-get update -y && apt-get install -y haskell-platform nginx \ 
	lmodern texlive-full libssh-dev  
RUN cabal update && cabal install pandoc
```

* Software not available through a package management system can be 
  downloaded and installed directly.
* Install *PLINK* by downloading the executable.

```docker
RUN cd /tmp && wget -q https://www.cog-genomics.org/static/bin/plink150507/plink_linux_x86_64.zip && unzip plink_linux_x86_64.zip && cp plink /usr/local/bin/ 
```

## Install R packages

* Can execute any command in the shell.
* Everything installed by previous commands is available.

```docker
RUN Rscript -e "biocLite(c('dplyr', 'tidyr', 'devtools', \
		'illuminaHumanv3.db', 'pander', 'ggdendro'))"
RUN Rscript -e "devtools::install_github('hadley/readr')"
```

## Setting-up the analysis {.small-header}

* Analysis uses two main files
	- Actual analysis contained in RMarkdown file
	- Driver script that runs *knitr* and *pandoc*, handles errors, 
	  copies the completed report to the web server, etc.

## Include analysis scripts {.small-header}

Add data and code to the image

```docker
COPY data/ /analysis/data/
COPY heatshock_analysis.* default.pandoc /analysis/
```

## Running the analysis

* Bioconductor uses [Supervisor](http://supervisord.org/) to run RStudio
* Adapt *Supervisor* config file to also run the analysis on startup.

```config
[program:analysis]
command=/usr/bin/Rscript /analysis/analysis.r
autostart=true
autorestart=false
stdout_logfile=/analysis/log/%(program_name)s.log
stderr_logfile=/analysis/log/%(program_name)s.log
```

```docker
COPY config/supervisored.conf /tmp/
RUN cat /tmp/supervisored.conf >> /etc/supervisor/conf.d/supervisord.conf
```

## Displaying results

* Generate report using [knitr](http://yihui.name/knitr/) and 
  [pandoc](http://pandoc.org/).
* Use [nginx](http://nginx.org/en/) to serve resulting web page.
* May want to [restrict access](http://nginx.com/resources/admin-guide/restricting-access/) 
  prior to publication.

# Using the Docker image

## Starting the container {.small-header}

* Share host directory with container to store *knitr* cache to 
  allow cache to persist beyond lifetime of container.
* Map ports for RStudio and web site to host ports.

```sh
docker run -v /path/to/project/analysis/cache/:/analysis/cache/ \
	-p 9999:80 -p 8787:8787 analysis
```

## Viewing results

* Access the HTML report at `http://<docker.host.address>:9999`
* Further explore the data and results interactively through
  RStudio running at `http://<docker.host.address>:8787`.

# Summary

## Advantages

* Docker provides a stable environment for analysis
* Can be used to distribute data, analysis and results
* Makes it much easier to reproduce results

## Limitations

* Docker images can become large (and accumulate on the host)
* Running docker requires root access
* Sharing files with the host can be tricky
