#!/bin/bash

# setup-terraform-backend
# A script to provision Azure infrastructure resources required for Terraform backend-config state
# The following resources are created:
# - Resource group
# - Storage account
# - Storage container

usage()
{
    cat << EOF
usage: setup-terraform-backend [-h --help] [--debug]
                               -g --resource-group 
                               -l --location
                               --storage-account-name
                               [--storage-account-sku]
                               --storage-container-name
EOF
}

##### Parameters

GROUP_NAME=
LOCATION=
STORAGE_ACCOUNT_NAME=
STORAGE_ACCOUNT_SKU=Standard_LRS
STORAGE_CONTAINER_NAME=
DEBUG=

##### Functions

join()( local IFS="$1"; shift; echo "$*"; )
error()(echo "$1" | sed $'s,.*,\e[31m&\e[m,')

##### Main

while [ "$1" != "" ]; do
    case $1 in
        -g | --resource-group )     shift
                                    GROUP_NAME=$1
                                    ;;
        -l | --location )           shift
                                    LOCATION=$1
                                    ;;
        --storage-account-name )    shift
                                    STORAGE_ACCOUNT_NAME=$1
                                    ;;
        --storage-account-sku )     shift
                                    STORAGE_ACCOUNT_SKU=$1
                                    ;;
        --storage-container-name )  shift
                                    STORAGE_CONTAINER_NAME=$1
                                    ;;
        --debug )                   DEBUG=1
                                    ;;
        -h | --help )               usage
                                    exit
    esac
    shift
done

missing_args=()

if [ -z "$GROUP_NAME" ]; then
  missing_args+=("--resource-group/-g")
fi
if [ -z "$LOCATION" ]; then
  missing_args+=("--location/-l")
fi
if [ -z "$STORAGE_ACCOUNT_NAME" ]; then
  missing_args+=("--storage-account-name")
fi
if [ -z "$STORAGE_CONTAINER_NAME" ]; then
  missing_args+=("--storage-container-name")
fi

if [ ${#missing_args[@]} -ne 0 ]; then
  error "The following arguments are required: "$(join , "${missing_args[@]}") >&2
  usage
  exit 1
fi

# Create resource group
if [ "$DEBUG" = "1" ]; then
  echo "Creating resource group..."
fi

az group create -g $GROUP_NAME -l $LOCATION

if [ $? -ne 0 ]; then
  exit 1
fi

if [ "$DEBUG" = "1" ]; then
  echo "Resource group created."
fi

# Create storage account
if [ "$DEBUG" = "1" ]; then
  echo "Creating storage account..."
fi

az storage account create -n $STORAGE_ACCOUNT_NAME -g $GROUP_NAME -l $LOCATION --sku $STORAGE_ACCOUNT_NAME

if [ $? -ne 0 ]; then
  exit 1
fi

if [ "$DEBUG" = "1" ]; then
  echo "Storage account created."
fi

# Create storage container
if [ "$DEBUG" = "1" ]; then
  echo "Creating storage container..."
fi

az storage container create -n $STORAGE_CONTAINER_NAME --account-name $STORAGE_ACCOUNT_NAME

if [ $? -ne 0 ]; then
  exit 1
fi

if [ "$DEBUG" = "1" ]; then
  echo "Storage container created."
fi
