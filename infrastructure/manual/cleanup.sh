#!/bin/bash

# cleanup
# A script to cleanup Azure infrastructure resources
# The following resources are removed:
# - Resource group
# - AKS resource group
# - Service principal



usage()
{
    cat << EOF
usage: cleanup [-h --help] [--debug]
               -g --resource-group 
EOF
}

##### Parameters

GROUP_NAME=
AKS_GROUP_NAME=NetworkWatcherRG
DEBUG=

##### Functions

join()( local IFS="$1"; shift; echo "$*"; )
error()(echo "$1" | sed $'s,.*,\e[31m&\e[m,')

##### Main

while [ "$1" != "" ]; do
    case $1 in
        -g | --resource-group ) shift
                                GROUP_NAME=$1
                                ;;
        --debug )               DEBUG=1
                                ;;
        -h | --help )           usage
                                exit
    esac
    shift
done

missing_args=()

if [ -z "$GROUP_NAME" ]; then
  missing_args+=("--resource-group/-g")
fi

if [ ${#missing_args[@]} -ne 0 ]; then
  error "The following arguments are required: "$(join , "${missing_args[@]}") >&2
  usage
  exit 1
fi

# Delete resource group
if [ "$DEBUG" = "1" ]; then
  echo "Deleting resource group..."
fi

az group delete -g $GROUP_NAME --yes

if [ $? -ne 0 ]; then
  exit 1
fi

if [ "$DEBUG" = "1" ]; then
  echo "Resource group deleted."
fi

# Delete AKS resource group
if [ "$DEBUG" = "1" ]; then
  echo "Deleting AKS resource group..."
fi

az group delete -g $AKS_GROUP_NAME --yes

if [ $? -ne 0 ]; then
  exit 1
fi

if [ "$DEBUG" = "1" ]; then
  echo "AKS Resource group deleted."
fi

# Delete service principal
if [ "$DEBUG" = "1" ]; then
  echo "Deleting service principal..."
fi

SERVICE_PRINCIPAL=$(az ad sp list --filter "displayname eq '$GROUP_NAME'")
if [ "$(jq -nR "$SERVICE_PRINCIPAL" | jq -r .[0].appId)" = 'null' ]; then
  error "Service principal $GROUP_NAME not found." >&2
  exit 1
fi

az ad sp delete --id $(jq -nR "$SERVICE_PRINCIPAL" | jq -r .[0].appId)

if [ $? -ne 0 ]; then
  exit 1
fi

if [ "$DEBUG" = "1" ]; then
  echo "Service principal deleted."
fi
