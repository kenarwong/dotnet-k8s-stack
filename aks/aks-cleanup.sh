az group delete -g $GROUPNAME --yes; az group delete -g NetworkWatcherRG --yes
az ad sp delete --id $(jq -nR "$SERVICE_PRINCIPAL" | jq -r .appId)
