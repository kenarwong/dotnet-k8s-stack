#!/bin/bash

# setup 
# A script to setup Azure infrastructure resources required for dotnet-k8s-stack
# Provisions the following:
# - Resource group
# - Static public IP
#   - Used for ingress
# - DNS Zone
#   - Used for DNS Delegation for a public domain
# - DNS Zone Role Assignment
#   - Used to satisfy Let's Encrypt DNS01 challenges
# - 1 A record 
#   - Used for ingress
# - 2 CNAME records
#   - Used for ingress subdomains
# - Virtual Network
#   - Used by AKS for network policies
# - Subnet
#   - Used by AKS for network policies
# - Network Contributor Role Assignment
#   - Used by AKS for network policies
# - Azure Kubernetes Service
# - Azure Container Registry
# - ACR Role Assignment
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
             [--vnet-name]
             [--subnet-name]
             --cert-manager-service-principal
             --kubernetes-service-principal
             --kubernetes-client-secret
             [-c --node-count]
EOF
}

##### Parameters

GROUP_NAME=
LOCATION=
CLUSTER_NAME=
DOMAIN_NAME=
ACR_NAME=
VNET_NAME="aks-vnet"
SUBNET_NAME="aks-subnet"
CERT_MANAGER_SERVICE_PRINCIPAL=
KUBERNETES_SERVICE_PRINCIPAL=
KUBERNETES_CLIENT_SECRET=
NODE_COUNT=2
DEBUG=

##### Functions

join()( local IFS="$1"; shift; echo "$*"; )
error()(echo "$1" | sed $'s,.*,\e[31m&\e[m,')

##### Main

while [ "$1" != "" ]; do
    case $1 in
        -g | --resource-group )             shift
                                            GROUP_NAME=$1
                                            ;;
        -l | --location )                   shift
                                            LOCATION=$1
                                            ;;
        -n | --name )                       shift
                                            CLUSTER_NAME=$1
                                            ;;
        --domain-name )                     shift
                                            DOMAIN_NAME=$1
                                            ;;
        --acr-name )                        shift
                                            ACR_NAME=$1
                                            ;;
        --vnet-name )                       shift
                                            VNET_NAME=$1
                                            ;;
        --subnet-name )                     shift
                                            SUBNET_NAME=$1
                                            ;;
        --cert-manager-service-principal )  shift
                                            CERT_MANAGER_SERVICE_PRINCIPAL=$1
                                            ;;
        --kubernetes-service-principal )    shift
                                            KUBERNETES_SERVICE_PRINCIPAL=$1
                                            ;;
        --kubernetes-client-secret )        shift
                                            KUBERNETES_CLIENT_SECRET=$1
                                            ;;
        -c | --node-count )                 shift
                                            NODE_COUNT=$1
                                            ;;
        --debug )                           DEBUG=1
                                            ;;
        -h | --help )                       usage
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
if [ -z "$CERT_MANAGER_SERVICE_PRINCIPAL" ]; then
  missing_args+=("--cert-manager-service-principal")
fi
if [ -z "$KUBERNETES_SERVICE_PRINCIPAL" ]; then
  missing_args+=("--kubernetes-service-principal")
fi
if [ -z "$KUBERNETES_CLIENT_SECRET" ]; then
  missing_args+=("--kubernetes-client-secret")
fi

if [ ${#missing_args[@]} -ne 0 ]; then
  error "The following arguments are required: "$(join , "${missing_args[@]}") >&2
  usage
  exit 1
fi

### Resource Group ###
# Create resource group
if [ "$DEBUG" = "1" ]; then
  echo "Creating resource group..."
fi

RESOURCE_GROUP_ID=$(az group create -g $GROUP_NAME -l $LOCATION --query id -o tsv)

if [ $? -ne 0 ]; then
  exit 1
fi

if [ "$DEBUG" = "1" ]; then
  echo "Resource group created."
fi

### Public Resources ###
# Create static public IP
if [ "$DEBUG" = "1" ]; then
  echo "Creating Static IP..."
fi

PUBLIC_IP=$(az network public-ip create -g $GROUP_NAME --name $CLUSTER_NAME-public-ip --sku Standard --allocation-method static --query publicIp.ipAddress -o tsv)
PUBLIC_IP_ID=$(az network public-ip list --query "[?ipAddress=='$PUBLIC_IP'].id" -o tsv)

if [ $? -ne 0 ]; then
  exit 1
fi

if [ "$DEBUG" = "1" ]; then
  echo "Static IP created."
fi

# Create DNS Zone
if [ "$DEBUG" = "1" ]; then
  echo "Creating DNS Zone..."
fi

DNS_ID=$(az network dns zone create -g $GROUP_NAME -n $DOMAIN_NAME --query id -o tsv)

if [ $? -ne 0 ]; then
  exit 1
fi

if [ "$DEBUG" = "1" ]; then
  echo "DNS Zone created."
fi

# Create DNS Zone Role Assignment
if [ "$DEBUG" = "1" ]; then
  echo "Creating DNS Zone Role Assignment..."
fi

az role assignment create --assignee $CERT_MANAGER_SERVICE_PRINCIPAL --role "DNS Zone Contributor" --scope $DNS_ID

if [ $? -ne 0 ]; then
  exit 1
fi

if [ "$DEBUG" = "1" ]; then
  echo "DNS Zone Role Assignment created."
fi

# Create A record
if [ "$DEBUG" = "1" ]; then
  echo "Creating A record..."
fi

# Create temporary A record
az network dns record-set a add-record -g $GROUP_NAME --record-set-name @ --zone-name $DOMAIN_NAME --ipv4-address 1.1.1.1

if [ $? -ne 0 ]; then
  exit 1
fi

# Update temporary record to point to public IP resource
az network dns record-set a update --name @ -g $GROUP_NAME --zone-name $DOMAIN_NAME --target-resource $PUBLIC_IP_ID

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

az network dns record-set cname set-record -g $GROUP_NAME --zone-name $DOMAIN_NAME --record-set-name api --cname $DOMAIN_NAME

if [ $? -ne 0 ]; then
  exit 1
fi

az network dns record-set cname set-record -g $GROUP_NAME --zone-name $DOMAIN_NAME --record-set-name '*' --cname $DOMAIN_NAME

if [ $? -ne 0 ]; then
  exit 1
fi

if [ "$DEBUG" = "1" ]; then
  echo "CNAME records created."
fi

### Azure Kubernetes Service ###
# Create Virtual Network and Subnet
if [ "$DEBUG" = "1" ]; then
  echo "Creating Virtual Network and Subnet..."
fi

az network vnet create \
      -g $GROUP_NAME \
      --name $VNET_NAME \
      --address-prefixes 10.0.0.0/8 \
      --subnet-name $SUBNET_NAME \
      --subnet-prefix 10.240.0.0/16

SUBNET_ID=$(az network vnet subnet show -g $GROUP_NAME --vnet-name $VNET_NAME --name $SUBNET_NAME --query id -o tsv)

if [ $? -ne 0 ]; then
  exit 1
fi

if [ "$DEBUG" = "1" ]; then
  echo "Virtual Network and Subnet created."
fi

# Create Network Contributor Role Assignment
if [ "$DEBUG" = "1" ]; then
  echo "Creating Network Contributor Role Assignment..."
fi

az role assignment create --assignee $KUBERNETES_SERVICE_PRINCIPAL --role "Network Contributor" --scope $RESOURCE_GROUP_ID

if [ $? -ne 0 ]; then
  exit 1
fi

if [ "$DEBUG" = "1" ]; then
  echo "Network Contributor Role Assignment created."
fi

# Create AKS
if [ "$DEBUG" = "1" ]; then
  echo "Creating AKS..."
fi

az aks create \
      -g $GROUP_NAME \
      -n $CLUSTER_NAME \
      -c $NODE_COUNT \
      --vnet-subnet-id $SUBNET_ID \
      --network-plugin kubenet \
      --network-policy calico \
      --service-principal $KUBERNETES_SERVICE_PRINCIPAL \
      --client-secret $KUBERNETES_CLIENT_SECRET

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

# Create ACR Role Assignment
if [ "$DEBUG" = "1" ]; then
  echo "Creating ACR Role Assignment..."
fi

az role assignment create --role acrPull --assignee $KUBERNETES_SERVICE_PRINCIPAL --scope $(jq -nR "$(az group show -g $GROUP_NAME)" | jq -r .id)

if [ $? -ne 0 ]; then
  exit 1
fi

if [ "$DEBUG" = "1" ]; then
  echo "ACR Role Assignment created."
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
