ACRNAME=kecoacr

az acr create -n $ACRNAME -g $GROUPNAME --sku Basic
az role assignment create --role acrPull --assignee $(jq -nR "$SERVICE_PRINCIPAL" | jq -r .appId) --scope $(jq -nR "$(az group show -g $GROUPNAME)" | jq -r .id)
az acr login -n $ACRNAME
