#!/bin/bash

# setup 
# A script to setup Azure infrastructure resources required for dotnet-k8s-stack
# Provisions the following:
# - Resource group
# - Azure Kubernetes Service
# - Static public IP
#   - Used for ingress
# - DNS Zone
#   - Used for DNS Delegation for a public domain
# - 1 A record 
#   - Used for ingress
# - 2 CNAME records
#   - Used for ingress subdomains
# - Azure Container Registry
# - ACR role assignment
#   - Used by service principal image pulling


usage()
{
    cat << EOF
usage: setup [-h --help] [--debug]
             -g --resource-group 
             -l --location
             -n --name
             --domain-name
             --acr-name
             --service-principal
             --client-secret
             [-c --node-count]
EOF
}

##### Parameters

GROUP_NAME=
LOCATION=
CLUSTER_NAME=
DOMAIN_NAME=
ACR_NAME=
SERVICE_PRINCIPAL=
CLIENT_SECRET=
NODE_COUNT=2
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
        -l | --location )       shift
                                LOCATION=$1
                                ;;
        -n | --name )           shift
                                CLUSTER_NAME=$1
                                ;;
        --domain-name )         shift
                                DOMAIN_NAME=$1
                                ;;
        --acr-name )            shift
                                ACR_NAME=$1
                                ;;
        --service-principal )   shift
                                SERVICE_PRINCIPAL=$1
                                ;;
        --client-secret )       shift
                                CLIENT_SECRET=$1
                                ;;
        -c | --node-count )     shift
                                NODE_COUNT=$1
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
if [ -z "$LOCATION" ]; then
  missing_args+=("--location/-l")
fi
if [ -z "$CLUSTER_NAME" ]; then
  missing_args+=("--name/-n")
fi
if [ -z "$DOMAIN_NAME" ]; then
  missing_args+=("--domain-name")
fi
if [ -z "$ACR_NAME" ]; then
  missing_args+=("--acr-name")
fi
if [ -z "$SERVICE_PRINCIPAL" ]; then
  missing_args+=("--service-principal")
fi
if [ -z "$CLIENT_SECRET" ]; then
  missing_args+=("--client-secret")
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

# Create AKS with service principal
if [ "$DEBUG" = "1" ]; then
  echo "Creating AKS..."
fi

az aks create -g $GROUP_NAME -n $CLUSTER_NAME -c $NODE_COUNT --service-principal $SERVICE_PRINCIPAL --client-secret $CLIENT_SECRET

if [ $? -ne 0 ]; then
  exit 1
fi

if [ "$DEBUG" = "1" ]; then
  echo "AKS created."
fi

# Update kubernetes config with AKS credentials
if [ "$DEBUG" = "1" ]; then
  echo "Setting AKS credentials..."
fi

az aks get-credentials -g $GROUP_NAME -n $CLUSTER_NAME --overwrite

if [ $? -ne 0 ]; then
  exit 1
fi

if [ "$DEBUG" = "1" ]; then
  echo "AKS credentials set"
fi

# Create static public IP
if [ "$DEBUG" = "1" ]; then
  echo "Creating Static IP..."
fi

CLUSTER_RESOURCE_GROUP=$(az aks show  -g $GROUP_NAME -n $CLUSTER_NAME --query nodeResourceGroup -o tsv)
PUBLIC_IP=$(az network public-ip create --resource-group $CLUSTER_RESOURCE_GROUP --name $CLUSTER_NAME-public-ip --sku Standard --allocation-method static --query publicIp.ipAddress -o tsv)
PUBLIC_IP_ID=$(az network public-ip list --query "[?ipAddress=='$PUBLIC_IP'].id" -o tsv)

if [ $? -ne 0 ]; then
  exit 1
fi

if [ "$DEBUG" = "1" ]; then
  echo "Static IP created."
fi

# Create DNS zone
if [ "$DEBUG" = "1" ]; then
  echo "Creating DNS Zone..."
fi

az network dns zone create -g $CLUSTER_RESOURCE_GROUP -n $DOMAIN_NAME

if [ $? -ne 0 ]; then
  exit 1
fi

if [ "$DEBUG" = "1" ]; then
  echo "DNS Zone created."
fi

# Create A record
if [ "$DEBUG" = "1" ]; then
  echo "Creating A record..."
fi

# Create temporary A record
az network dns record-set a add-record -g $CLUSTER_RESOURCE_GROUP --record-set-name @ --zone-name $DOMAIN_NAME --ipv4-address 1.1.1.1

if [ $? -ne 0 ]; then
  exit 1
fi

# Update temporary record to point to public IP resource
az network dns record-set a update --name @ -g $CLUSTER_RESOURCE_GROUP --zone-name $DOMAIN_NAME --target-resource $PUBLIC_IP_ID

if [ $? -ne 0 ]; then
  exit 1
fi

if [ "$DEBUG" = "1" ]; then
  echo "A record created."
fi


# Create CNAME records
if [ "$DEBUG" = "1" ]; then
  echo "Creating CNAME records..."
fi

az network dns record-set cname set-record -g $CLUSTER_RESOURCE_GROUP --zone-name $DOMAIN_NAME --record-set-name api --cname $DOMAIN_NAME

if [ $? -ne 0 ]; then
  exit 1
fi

az network dns record-set cname set-record -g $CLUSTER_RESOURCE_GROUP --zone-name $DOMAIN_NAME --record-set-name '*' --cname $DOMAIN_NAME

if [ $? -ne 0 ]; then
  exit 1
fi

if [ "$DEBUG" = "1" ]; then
  echo "CNAME records created."
fi

# Create Azure Container Registry
if [ "$DEBUG" = "1" ]; then
  echo "Creating ACR..."
fi

az acr create -n $ACR_NAME -g $GROUP_NAME --sku Basic

if [ $? -ne 0 ]; then
  exit 1
fi

if [ "$DEBUG" = "1" ]; then
  echo "ACR created."
fi

# Create ACR role assignment
if [ "$DEBUG" = "1" ]; then
  echo "Creating ACR role assignment..."
fi

az role assignment create --role acrPull --assignee $SERVICE_PRINCIPAL --scope $(jq -nR "$(az group show -g $GROUP_NAME)" | jq -r .id)

if [ $? -ne 0 ]; then
  exit 1
fi

if [ "$DEBUG" = "1" ]; then
  echo "ACR role assignment created."
fi

# Login to ACR
if [ "$DEBUG" = "1" ]; then
  echo "Logging into ACR..."
fi

az acr login -n $ACR_NAME

if [ $? -ne 0 ]; then
  exit 1
fi

if [ "$DEBUG" = "1" ]; then
  echo "Logged into ACR."
fi
