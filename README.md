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


# AKS cluster setup

## Create AKS cluster

`ansible-playbook play_setup_aks.yml -e "service_principal=<service_principal_id> client_secret=<client_secret>" -e @env_vars/env-<dev or prod>.yml`

## Setup tiller and install azure key vault controller

Install [Helm](https://helm.sh/docs/using_helm/) if you don't have it

```
kubectl apply -f ./kubernetes-manifests/assets/tiller-setup.yml
helm init --service-account tiller
```
```
helm repo add spv-charts http://charts.spvapi.no
helm repo update

helm install spv-charts/azure-key-vault-controller
```

## Azure Key Vault Setup

Creating Azure key vault if you don't existing one already.
* Run `ansible-playbook play_setup_keyvault.yml -e @env_vars/env-<dev or prod>.yml`

When key vault has been created

* Run following commands to give AKS-cluster permissions to read from key vault
```
az role assignment create --role Reader --assignee <service_principal_clientid> --scope <keyvault_resource_id>

az keyvault set-policy -n <keyvault_name> --key-permissions get --spn <YOUR SPN CLIENT ID>
az keyvault set-policy -n <keyvault_name> --secret-permissions get --spn <YOUR SPN CLIENT ID>
az keyvault set-policy -n <keyvault_name> --certificate-permissions get --spn <YOUR SPN CLIENT ID>
```

When AKS-cluster has permissions to read from key vault, you can following command to add kube-secrets

```
kubectl apply -f ./kubernetes-manifests/assets/keyvaultsecrets.yml
```

When secrets have been added to AKS cluster, you can start deploying services to cluster.

## Application Gateway setup

* Run `ansible-playbook play_setup_appgw.yml -e @env_vars/env-<dev or prod>.yml`

## Azure Api Management setup
* Read the docs: [Create Azure Api Management](https://docs.microsoft.com/en-us/azure/api-management/get-started-create-service-instance)


## Integrate Api Management and Application Gateway

Configure Api Management's vnet to internal mode so it is accessible only through Application Gateway. [Read here for more information](https://docs.microsoft.com/en-us/azure/api-management/get-started-create-service-instance)

### Peering vnets
Following commands create peering connections between AKS cluster and application gateway and Api Management. Peering connections has to be created so that application gateway can connect to AKS cluster using internal ip.

```
az network vnet peering create -g <appgw_resource_group> -n <peering_name> --vnet-name <appgw_vnet_name> --remote-vnet <aks_vnet_resource_id> --allow-vnet-access
```

```
az network vnet peering create -g <aks_resource_group> -n <peering_name> --vnet-name <aks_vnet_name> --remote-vnet <appgw_vnet_resource_id> --allow-vnet-access
```