GROUPNAME=k-eco
LOCATION=eastus
CLUSTERNAME=k-cluster
NODECOUNT=2

# Create resource group
az group create -g $GROUPNAME -l $LOCATION

# Create service principal
SERVICE_PRINCIPAL=$(az ad sp create-for-rbac -n https://$GROUPNAME --skip-assignment)
sleep 15; # wait for for service principal to propagate

# Create AKS with service principal
az aks create -g $GROUPNAME -n $CLUSTERNAME -c $NODECOUNT --service-principal $(jq -nR "$SERVICE_PRINCIPAL" | jq -r .appId) --client-secret $(jq -nR "$SERVICE_PRINCIPAL" | jq -r .password)

# Update kubernetes config with AKS credentials
az aks get-credentials -g $GROUPNAME -n $CLUSTERNAME --overwrite

# Create static public IP
CLUSTER_RESOURCE_GROUP=$(az aks show  -g k-eco -n k-cluster --query nodeResourceGroup -o tsv)
PUBLIC_IP=$(az network public-ip create --resource-group $CLUSTER_RESOURCE_GROUP --name k-cluster-public-ip --sku Standard --allocation-method static --query publicIp.ipAddress -o tsv)
