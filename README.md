# Digitransit AKS (Azure Kubernetes Service) API backend

## Contents
This repository contains the service definitions for Digitransit's API backend, specifically the following:
* Deployment scripts for Azure Kubernetes Service (AKS)
* Kubernetes service and deployment definition YAML's for Digitransit API's
* Azure API Management deployment scripts
* API product definitions

Folders in this repository might contain separate instruction files as needed.

NOTE: This is a living document during the migration project, and subject to frequent updates.

## Prerequisites to using this repository
* Access to an Azure subscription
* Docker installed on your local environment

## How to use
* Run script *start-ansible-shell.sh*
    * This starts an instance of HSL's Ansible toolkit, which is a Docker container locally with Azure CLI and Ansible pre-installed
* Follow the instructions to log in to an Azure account with your Azure credentials (note also the DEFAULT_SUBSCRIPTION variable in the script)
* *For interacting with AKS*: When you start the management container, install kubectl and connect to the cluster as follows:
    * Install kubectl: `az aks install-cli`
    * Connect to cluster: `az aks get-credentials --resource-group <your resource group> --name <your AKS cluster name>`
    * Test connection: `kubectl get nodes`
    * More instructions here: https://docs.microsoft.com/en-us/azure/aks/kubernetes-walkthrough#connect-to-the-cluster


## Development guidelines
NOTE: Guidelines are subject to change as project progresses.

**template.yml**
* Template for kubernetes manifests is prvided in /aks-deployment/files. Use this to create new configurations for deployments and services. 

**Variables**
* Use folder *group_vars* for variables that do not vary between deployments or environments, such as the naming convention of resources

* Use folder *env_vars* for variables that DO vary between deployments or environments, such as the number of nodes in an AKS cluster

* In folder *group_vars*, use file *all* for generic variables (e.g. Resource Group namings, variables related to subscription etc.)

**Kubernetes definitions**
* Use a similar folder structure as currently with https://github.com/HSLdevcom/digitransit-mesos-deploy/tree/master/digitransit-azure-deploy 
    * All deployment definitions go under one role (to be specified)
    * Create a separate YAML file for deploying each service (folder to be specified)

* By default use Kubernetes YAML's for service and deployment definitions instead of Helm charts

## How to contribute
To be added
