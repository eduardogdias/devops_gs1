# Variáveis
RESOURCE_GROUP="rg-gs"
LOCATION="brazilsouth"
VM_NAME="vm-linux-gs"
IMAGE="almalinux:almalinux-x86_64:9-gen2:9.5.202411260"
SIZE="Standard_B2ms" #2 CPU | 8 RAM
ADMIN_USERNAME="admlnx"
ADMIN_PASSWORD="Fiap@2tdsvms"
DISK_SKU="StandardSSD_LRS"
PORT1=8080 #spring
PORT2=1521 #Oracle

#---------------------------------------------

# Criando grupo de recursos
echo "Criando grupo de recursos: $RESOURCE_GROUP..."
az group create --name $RESOURCE_GROUP --location $LOCATION

# Criando a VM
echo "Criando a máquina virtual: $VM_NAME..."
az vm create \
  --resource-group $RESOURCE_GROUP \
  --name $VM_NAME \
  --image $IMAGE \
  --size $SIZE \
  --authentication-type password \
  --admin-username $ADMIN_USERNAME \
  --admin-password $ADMIN_PASSWORD \
  --storage-sku $DISK_SKU \
  --public-ip-sku Basic

# Abrindo as portas 8080 e 1521
echo "Abrindo a primeira porta: $PORT1 para o Spring..."
az vm open-port --port $PORT1 --priority 1001 --resource-group $RESOURCE_GROUP --name $VM_NAME #novo parametro usado: --priority

echo "Abrindo a segunda porta: $PORT2 para o Oracle..."
az vm open-port --port $PORT2 --priority 1002 --resource-group $RESOURCE_GROUP --name $VM_NAME

# Instalar Git na VM após a criação
echo "Instalando o Git e Nano dentro da VM"
az vm run-command invoke \
  --resource-group $RESOURCE_GROUP \
  --name $VM_NAME \
  --command-id RunShellScript \
  --scripts "sudo yum install git nano -y"

# Instalar Docker na VM após a criação
echo "Instalando e configurando Docker na VM"
az vm run-command invoke \
  --resource-group $RESOURCE_GROUP \
  --name $VM_NAME \
  --command-id RunShellScript \
  --scripts "sudo yum install -y yum-utils &&
             sudo yum-config-manager --add-repo https://download.docker.com/linux/rhel/docker-ce.repo &&
             sudo yum install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin &&
             sudo systemctl start docker &&
             sudo systemctl enable docker.service &&  
             sudo systemctl enable containerd.service &&
             sudo usermod -aG docker admlnx" 
             
             # 1. Instalar o Docker
             # 2. Inicializar o Docker junto com o  sistema
             # 3. incluir o nosso usuário no grupo de usuário do Docker


echo "✅  VM criada com sucesso com Git instalado!"


#---------------------------------------------

# Após o upload do script no Azure CLI:

# 1. Conceder privilégio de execução
# chmod 744 criar-vm-sprint1-git-nano-docker.sh 

# 2. Executar o script
# ./criar-vm-sprint1-git-nano-docker.sh 
