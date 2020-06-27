GROUPNAME=k-eco
LOCATION=eastus
CLUSTERNAME=k-cluster
NODECOUNT=2
DOMAIN_NAME=kenrhwang.com

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

# Create DNS zone
PUBLIC_IP_ID=$(az network public-ip list --query "[?ipAddress=='$PUBLIC_IP'].id" -o tsv)
az network dns zone create -g $GROUPNAME -n $DOMAIN_NAME

# Create temporary A record
az network dns record-set a add-record -g $GROUPNAME --record-set-name @ --zone-name $DOMAIN_NAME --ipv4-address 1.1.1.1

# Update temporary record to point to public IP resource
az network dns record-set a update --name @ -g $GROUPNAME --zone-name $DOMAIN_NAME --target-resource $PUBLIC_IP_ID

# Create CNAME records
az network dns record-set cname set-record -g $GROUPNAME --zone-name $DOMAIN_NAME --record-set-name api --cname $DOMAIN_NAME
az network dns record-set cname set-record -g $GROUPNAME --zone-name $DOMAIN_NAME --record-set-name '*' --cname $DOMAIN_NAME

