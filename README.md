# Digitransit AKS (Azure Kubernetes Service) API backend

## Contents
This repository contains the service definitions for Digitransit's API backend, specifically the following:
* Deployment scripts for Azure Kubernetes Service (AKS)
* Kubernetes service and deployment definition YAML's for Digitransit API's
* Azure API Management deployment scripts
* API product definitions

Folders in this repository might contain separate instruction files as needed.

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

**Variables**
* Use folder *group_vars* for variables that do not vary between deployments or environments, such as the naming convention of resources
    * In folder *group_vars*, use file *all* for generic variables (e.g. Resource Group namings, variables related to subscription etc.)

* Use folder *env_vars* for variables that DO vary between deployments or environments, such as the number of nodes in an AKS cluster

**Kubernetes manifest definitions**
* Reside under /roles/aks-apply/files/
    * Use assets directory for files that should always be the same in both environments
    * Use environment named directories for rest of files that are or can be different in each environment
    * template.yml in the root defines a basic structure for a manifest

* By default use Kubernetes YAML's for service and deployment definitions instead of Helm charts

## How to contribute
To be added


# AKS cluster setup

## Create AKS cluster

Run following command to create AKS cluster.
```
ansible-playbook play_setup_aks.yml -e @env_vars/<dev or prod>.yml
```

It takes a bit before the AKS cluster is ready. The next command will configure addons for aks.
If the node pool for AKS is not yet properly deployed, running this command will fail.
Retry a bit later if that happens.
```
ansible-playbook play_configure_addons.yml -e @env_vars/<dev or prod>.yml
```

### Add Docker login to Kubernetes secrets

Run following command to create the secret for Docker login. Use the correct login credentials.
```
kubectl create secret docker-registry hsldevcomkey --docker-server=docker.io --docker-username=<username> --docker-password=<password>
```

### Install azure key vault controller

Install [Helm](https://helm.sh/docs/using_helm/) v3 if you don't have it

```
helm repo add spv-charts http://charts.spvapi.no

helm repo update

helm install spv-charts/azure-key-vault-controller --generate-name --version 1.0.2
```

Run following commands to give AKS-cluster permissions to read from key vault
```
az role assignment create --role Reader --assignee <service_principal_clientid> --scope <keyvault_resource_id>

az keyvault set-policy -n <keyvault_name> --key-permissions get --spn <YOUR SPN CLIENT ID>
az keyvault set-policy -n <keyvault_name> --secret-permissions get --spn <YOUR SPN CLIENT ID>
az keyvault set-policy -n <keyvault_name> --certificate-permissions get --spn <YOUR SPN CLIENT ID>
```

## Application Gateway setup

Run following command to create Application Gateway.
```
ansible-playbook play_setup_appgw.yml -e @env_vars/<dev or prod>.yml
```

## Azure Api Management setup

Run following command to create Api Management.
```
ansible-playbook play_setup_apim.yml -e "publisher_email=<email_address> publisher_name=<name>" -e @env_vars/<dev or prod>.yml
```

## Connecting Api Mangement and Application Gateway to AKS cluster

### OPTION 1: Network security group (**Basic** or **Standard** tier of Api Management)

To connect Api Management and Application Gateway to AKS cluster, you'll need to add following inbound security rules to AKS cluster's network security group. [Read here for more information about network security groups](https://docs.microsoft.com/en-us/azure/virtual-network/security-overview)

1. Allow traffic via TCP from Application Gateway's IP address to AKS cluster.
2. Allow traffic via TCP from API Management's IP address to AKS cluster.
3. Deny connection from internet to AKS cluster's public ip address. This rule should have lower priority than previous rules.

### Option 2: Peering vnets (**Premium** tier of Api Management)
Configure Api Management's vnet to internal mode so it is accessible only through Application Gateway. [Read here for more information](https://docs.microsoft.com/en-us/azure/api-management/get-started-create-service-instance)

Following commands create peering connections between AKS cluster and application gateway and Api Management. Peering connections has to be created so that application gateway can connect to AKS cluster using internal ip.

```
az network vnet peering create -g <appgw_resource_group> -n <peering_name> --vnet-name <appgw_vnet_name> --remote-vnet <aks_vnet_resource_id> --allow-vnet-access
```

```
az network vnet peering create -g <aks_resource_group> -n <peering_name> --vnet-name <aks_vnet_name> --remote-vnet <appgw_vnet_resource_id> --allow-vnet-access
```

## Azure Key Vault Setup

Creating Azure key vault if you don't existing one already.
* Run `ansible-playbook play_setup_keyvault.yml -e @env_vars/<dev or prod>.yml`

## Deploy kubernetes manifests

Applying all manifests into an environment (**Note you should have done all the earlier steps first**)
* Run `ansible-playbook play_apply_manifests.yml -e @env_vars/<dev or prod>.yml`

Applying a specific manifest into an environment
* Run `ansible-playbook play_apply_manifests.yml -e @env_vars/<dev or prod>.yml -e service=<filename without -env.yml postfix>`

## Deploy fav-service

Create a file fav_service_secrets.yml, and add following secrets to it.

```
"hslIdUrl": "<hslIdUrl>"
"clientId": "<clientId>"
"clientCredentials": "Basic <Base64 encoded clientCredentials (clienId:clientSecret)>"
```

Run following command to create Azure function app

```
ansible-playbook play_setup_fav_service.yml -e @env_vars/<dev or prod>.yml -e @fav_service_secrets.yml
```
