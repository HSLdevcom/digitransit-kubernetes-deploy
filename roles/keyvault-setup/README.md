# Azure Key Vault setup

## Contents

This role contains setupping Azure key vault and deploying secrets from key vault to kubernetes.

## Setup

* Run `ansible-playbook play_setup_keyvault.yml -e @vars=env_vars/env-dev.yml`

When key vault has been created in Azure

* Run following commands to give aks-cluster permissions to read from key vault
```
az role assignment create --role Reader --assignee <service_principal_clientid> --scope /subscriptions/<subscriptionid>/resourcegroups/<keyvault_rg_name>/providers/Microsoft.KeyVault/vaults/<keyvaultname>

az keyvault set-policy -n <keyvault_name> --key-permissions get --spn <YOUR SPN CLIENT ID>
az keyvault set-policy -n <keyvault_name> --secret-permissions get --spn <YOUR SPN CLIENT ID>
az keyvault set-policy -n <keyvault_name> --certificate-permissions get --spn <YOUR SPN CLIENT ID>
```