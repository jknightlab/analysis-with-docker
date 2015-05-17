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
