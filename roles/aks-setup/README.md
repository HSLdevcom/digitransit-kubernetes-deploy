# AKS cluster setup

## Create AKS cluster

`ansible-playbook play_setup_aks.yml -e "service_principal=<service_principal_id> client_secret=<client_secret>" -e @env_vars/env-dev.yml`

## Setup tiller and install azure key vault controller

Install [Helm](https://helm.sh/docs/using_helm/) if you don't have it

```
kubectl apply -f files/
helm init --service-account tiller
```
```
helm repo add spv-charts http://charts.spvapi.no
helm repo update

helm install spv-charts/azure-key-vault-controller
```

