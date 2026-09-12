#!/bin/bash
set -e

# ==============================================================================
# Clyvo Vet - Script de Deploy Automatizado 100% Azure CLI (Sprint 3)
# Opção Escolhida: Opção 1 - ACR + ACI (Solução Containerizada Completa: App + DB)
# Disciplina: DevOps Tools & Cloud Computing - FIAP
# ==============================================================================

# Definição de Variáveis Parametrizadas
RESOURCE_GROUP="rg-clyvo-devops-sprint3"
LOCATION="eastus" # Região com alta disponibilidade para ACI e ACR
ACR_NAME="acrclyvovet$RANDOM"
IMAGE_APP_NAME="clyvo-api:v1"
CONTAINER_GROUP_NAME="cg-clyvo-vet"
DNS_LABEL="clyvo-vet-api-$RANDOM"

# Credenciais do Banco (Variáveis de Ambiente - sem hardcode em código)
DB_USER=${DB_USER:-"RM562795"}
DB_PASSWORD=${DB_PASSWORD:-"FiapDevOps2026#"}

echo "===================================================================="
echo "🚀 INICIANDO DEPLOY COMPLETO NA AZURE (ACR + ACI)"
echo "Projeto: Clyvo Vet | Solução 100% Containerizada"
echo "Resource Group: $RESOURCE_GROUP | Região: $LOCATION"
echo "ACR Name: $ACR_NAME"
echo "===================================================================="

# 1. Criação do Grupo de Recursos
echo "[1/6] Criando Grupo de Recursos ($RESOURCE_GROUP)..."
az group create --name "$RESOURCE_GROUP" --location "$LOCATION" -o table

# 2. Criação do Azure Container Registry (ACR)
echo "[2/6] Criando Azure Container Registry ($ACR_NAME)..."
az acr create \
  --resource-group "$RESOURCE_GROUP" \
  --name "$ACR_NAME" \
  --sku Basic \
  --admin-enabled true \
  -o table

# Obter credenciais do ACR para o ACI poder puxar a imagem
echo "Obtendo credenciais do ACR..."
ACR_LOGIN_SERVER=$(az acr show --name "$ACR_NAME" --query loginServer --output tsv)
ACR_USERNAME=$(az acr credential show --name "$ACR_NAME" --query username --output tsv)
ACR_PASSWORD=$(az acr credential show --name "$ACR_NAME" --query "passwords[0].value" --output tsv)

# 3. Build da Imagem Docker na Nuvem via ACR Tasks (ou Docker local push)
echo "[3/6] Compilando e Enviando Imagem da Aplicação Java para o ACR via Azure Cloud Build..."
# Utiliza o Dockerfile existente com usuário não-root (USER appuser)
az acr build \
  --registry "$ACR_NAME" \
  --image "$IMAGE_APP_NAME" \
  .

# 4. Criação do Azure Container Instance (ACI) - Solução Completa Containerizada (App + Oracle DB)
# O ACI executa em um Container Group contendo a Aplicação (não-root) e o Banco de Dados em rede local compartilhada
echo "[4/6] Provisionando Azure Container Instances Multi-Container (App + Banco Containerizado)..."

# Gerar arquivo de configuração ACI com variáveis substituídas
export LOCATION
export CONTAINER_GROUP_NAME
export DNS_LABEL
export ACR_LOGIN_SERVER
export ACR_USERNAME
export ACR_PASSWORD
export IMAGE_APP_NAME
export DB_USER
export DB_PASSWORD

# Substitui as variáveis no template YAML gerando o arquivo final de deploy
envsubst < azure-aci-multicontainer.template.yaml > azure-aci-deployment.yaml

# Provisiona o Container Group via Azure CLI (Atendendo ao item 8.1 e 8.4)
az container create \
  --resource-group "$RESOURCE_GROUP" \
  --file azure-aci-deployment.yaml \
  -o table

# 5. Obtenção do Endereço Público e Teste de Conectividade
FQDN=$(az container show --resource-group "$RESOURCE_GROUP" --name "$CONTAINER_GROUP_NAME" --query ipAddress.fqdn --output tsv)
IP_PUBLICO=$(az container show --resource-group "$RESOURCE_GROUP" --name "$CONTAINER_GROUP_NAME" --query ipAddress.ip --output tsv)

echo "===================================================================="
echo "✅ DEPLOY CONCLUÍDO COM SUCESSO NO ACI!"
echo "===================================================================="
echo "Endereço FQDN: http://$FQDN:8080"
echo "IP Público: http://$IP_PUBLICO:8080"
echo "Swagger API Docs: http://$FQDN:8080/swagger-ui.html"
echo "Endpoints do CRUD CORE:"
echo " - Tutores: http://$FQDN:8080/api/tutores"
echo " - Pets:    http://$FQDN:8080/api/pets"
echo "===================================================================="
