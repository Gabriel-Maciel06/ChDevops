#!/bin/bash

# ==========================================
# Script de Automação Infra Azure (Sprint 1)
# ==========================================
# Este script atende às exigências da Tarefa 01 do Sprint de DevOps Tools & Cloud Computing:
# 1.1) Provisionar uma Máquina Virtual Linux na Azure
# 1.2) Abrir as portas necessárias ao projeto na VM
# 1.3) Instalar o Docker na VM criada
# 1.4) Instalar as ferramentas necessárias ao projeto (Git, nano etc)

# Variáveis do Projeto
RESOURCE_GROUP="rg-clyvo-devops"
LOCATION="eastus"
VM_NAME="vm-clyvo-app"
IMAGE="Ubuntu2204"
ADMIN_USER="azureuser"

echo "========================================="
echo "Iniciando Provisionamento na Azure..."
echo "========================================="

# 1. Criar o Grupo de Recursos
echo "[1/4] Criando Resource Group ($RESOURCE_GROUP)..."
az group create --name $RESOURCE_GROUP --location $LOCATION -o none

# 2. Criar a Máquina Virtual (Linux) com script de inicialização injetado
# O cloud-init.txt contém os comandos para instalar Git, Nano e Docker (Itens 1.3 e 1.4)
echo "[2/4] Criando Máquina Virtual ($VM_NAME) e instalando ferramentas (Docker, Git, Nano)..."

# Criando arquivo cloud-init para instalar dependências automaticamente
cat <<EOF > cloud-init.txt
#cloud-config
package_update: true
package_upgrade: true
packages:
  - git
  - nano
  - curl
  - apt-transport-https
  - ca-certificates
  - software-properties-common
runcmd:
  # Instalar Docker
  - curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg
  - echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
  - apt-get update
  - apt-get install -y docker-ce docker-ce-cli containerd.io docker-compose-plugin
  - usermod -aG docker $ADMIN_USER
  # Instalar Docker Compose (standalone para garantir compatibilidade com docker-compose.yml antigos)
  - curl -L "https://github.com/docker/compose/releases/download/v2.24.5/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
  - chmod +x /usr/local/bin/docker-compose
EOF

az vm create \
  --resource-group $RESOURCE_GROUP \
  --name $VM_NAME \
  --image $IMAGE \
  --admin-username $ADMIN_USER \
  --generate-ssh-keys \
  --custom-data cloud-init.txt \
  --output json

# 3. Abrir as Portas Necessárias (Item 1.2)
echo "[3/4] Abrindo portas no Firewall (8080 para API, 1521 para Banco, 22 para SSH)..."
# A porta 22 (SSH) já é aberta por padrão na criação da VM
az vm open-port --resource-group $RESOURCE_GROUP --name $VM_NAME --port 8080 --priority 1001 -o none
az vm open-port --resource-group $RESOURCE_GROUP --name $VM_NAME --port 1521 --priority 1002 -o none

# 4. Finalização e Resumo
PUBLIC_IP=$(az vm show -d -g $RESOURCE_GROUP -n $VM_NAME --query publicIps -o tsv)

echo "========================================="
echo "✅ Provisionamento Concluído com Sucesso!"
echo "========================================="
echo "IP Público da VM: $PUBLIC_IP"
echo "Para conectar na VM, use o comando:"
echo "ssh $ADMIN_USER@$PUBLIC_IP"
echo "========================================="
echo "OBS: Aguarde 2-3 minutos após a criação para que o script cloud-init termine a instalação do Docker em background."
