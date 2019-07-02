# Digitransit AKS (Azure Kubernetes Service) API backend

## Contents
This repository contains the service definitions for Digitransit's API backend, specifically the following:
* Deployment scripts for Azure Kubernetes Service (AKS)
* Kubernetes service and deployment definition YAML's for Digitransit API's
* Azure API Management deployment scripts
* API product definitions

## Prerequisites
* Access to an Azure subscription
* Docker installed on your local environment

## How to use
* Run script *start-ansible-shell.sh*
    * This starts a Docker container locally with Azure CLI and Ansible pre-installed
* Follow the instructions to log in to an Azure account with your Azure credentials (note also the DEFAULT_SUBSCRIPTION variable in the script)
* *For interacting with AKS*: Every time you start the management container,  install kubectl and connect to the cluster
    * See instructions here - https://docs.microsoft.com/en-us/azure/aks/kubernetes-walkthrough#connect-to-the-cluster


## Development guidelines
NOTE: Guidelines are subject to change as project progresses.

**Variables**
* Use folder *group_vars* for variables that do not vary between deployments or environments, such as the naming convention of resources

* Use folder *env_vars* for variables that DO vary between deployments or environments, such as the number of nodes in an AKS cluster

* In both folders, use separate YAML files for variables used by different resources (e.g. create a file for AKS, for API Management, etc.)

* In folder *group_vars*, use file *all* for generic variables (e.g. Resource Group namings, variables related to subscription etc.)

**Kubernetes definitions**
* By default use Kubernetes YAML's for service and deployment definitions instead of Helm charts

## How to contribute
To be added