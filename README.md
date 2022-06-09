# Digitransit AKS (Azure Kubernetes Service)

## Contents
This repository contains the service definitions for Digitransit's backend, specifically the following:
* Deployment scripts for Azure Kubernetes Service (AKS)
* Kubernetes service and deployment definition YAML's for Digitransit services
* Azure API Management deployment scripts

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
## Azure Key Vault Setup

Creating Azure key vault if you don't existing one already.
* Run `ansible-playbook play_setup_keyvault.yml -e @env_vars/<dev or prod>.yml`

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

## Deploy kubernetes manifests

Applying all manifests into an environment (**Note you should have done all the earlier steps first**)
* Run `ansible-playbook play_apply_manifests.yml -e @env_vars/<dev or prod>.yml`

Applying a specific manifest into an environment
* Run `ansible-playbook play_apply_manifests.yml -e @env_vars/<dev or prod>.yml -e service=<filename without -env.yml postfix>`

## Add kured for automated vm security updates

Add the Kured Helm repository
* Run `helm repo add kured https://weaveworks.github.io/kured`

Update your local Helm chart repository cache
* Run `helm repo update`

Create namespace for kured
* Run `kubectl create namespace kured`

Install kured (**Replace slack related values from the script with real values**)
* **For prod** Run `helm install kured kured/kured --namespace kured --set nodeSelector."beta\.kubernetes\.io/os"=linux --set configuration.slackChannel=<slack channel> --set configuration.slackHookUrl=<slack hook URL> --set configuration.slackUsername=<slack username for kured messages>`
* **For dev** Run `helm install kured kured/kured --namespace kured --set nodeSelector."beta\.kubernetes\.io/os"=linux --set configuration.startTime="14:00:00" --set configuration.endTime="20:00:00" --set configuration.rebootDays="{mon,tue,wed,thu,fri}" --set configuration.slackChannel=<slack channel> --set configuration.slackHookUrl=<slack hook URL> --set configuration.slackUsername=<slack username for kured messages>`

## Block traffic from internet

By default, traffic will be allowed directly from the internet to the kubernetes cluster. As Application Gateway and API Management are used for directing traffic to the cluster, incoming traffic should only be allowed from those two to the cluster.

There should be a resource group created with an autogenerated name that contains all the vms for the cluster. From there update the network security group to contain following incoming rules:
* Rule with < 400 priority that allows HTTP traffic from Application Gateway IP to cluster's IP (this is the IP given for digitransit-proxy service that can be checked with `kubectl get services`)
* Rule with < 400 priority that allows HTTP traffic from API Management IP to cluster's IP (this is the IP given for digitransit-proxy service that can be checked with `kubectl get services`)
* Rule with higher priority than the two previous rules but lower than 500 (500 and 501 priorities are used for autogenerated rules created by digitransit proxy's load balancer) that blocks traffic from Service Tag = Internet to the cluster's ip (this is the IP given for digitransit-proxy service that can be checked with `kubectl get services`)

## Enable application insights

This can be done through insights tab in the Azure portal for the cluster. Select an existing insights workspace if there is one.

If the project is being monitored through an external party, we should also add Monitoring Metrics Publisher role to the cluster's principal. This can be done through the insights tab in portal by clicking enable from the suggestion "Enable fast alerting experience on basic metrics for this Azure Kubernetes Services cluster. Learn more" on the top of the view or through az role assignment command. Enabling this requires Owner role on the cluster. More documentation https://docs.microsoft.com/en-us/azure/azure-monitor/containers/container-insights-update-metrics .

## Scaling nodes up

* It can be done through the AKS' node pools in the azure portal but we the dev/prod.yml files should also be updated to reflect the change in case we need to recreate environments
* There is a possibility that there will be SNAT port exhaustion which will cause issues with outbound flows to fail if nodes are increased but the load balancer is not updated. Therefore, before or right after the nodes have been scaled up, the total number of nodes (from all node pools) should be calculated. The current number of ports can be fetched `az network lb outbound-rule list --resource-group <the resource group automatically created by kubernetes for the load balancer and scale sets> --lb-name kubernetes -o table` and the number of ip addesses can be at least seen from the kubernetes load balancer's frontend ip configuration in the Azure portal (the outbound ips in our case should be the total number of ips - 1). To calculate what should be the appropriate number of ports and ips follow the https://docs.microsoft.com/en-us/azure/aks/load-balancer-standard#configure-the-allocated-outbound-ports documentation. We should have room for a couple of extra nodes so therefore the calculation should be something like `64,000 ports per IP / <outbound ports per node> * <number of outbound IPs> = <number of nodes in the cluster> + 2`. The outbound ports should be a multiple of 8.

## Upgrading AKS version

* Check that there are no PodDisruptionBudgets that would block a node from being drained for upgrade. This can be done with `kubectl describe poddisruptionbudgets` and all entries should have Allowed disruptions > 0.
* Remove a rule that blocks all incoming traffic from internet from the cluster's network security group temporarily for the upgrade
* Check available versions with `az aks get-versions --location westeurope --output table` and pick the highest version that is not in preview state. If there are more than 1 major version update, the upgrade should be done one major version update at a time.
* Version can be upgraded through `az aks upgrade --resource-group <rg> --name <cluster name> --kubernetes-version <version>`


# Application Gateway setup

Run following command to create Application Gateway.
```
ansible-playbook play_setup_appgw.yml -e @env_vars/<dev or prod>.yml
```

# Azure Api Management setup

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
# Deploy fav-service

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
