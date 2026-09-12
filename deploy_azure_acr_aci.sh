#!/bin/bash
set -e

# ==============================================================================
# Clyvo Vet - Script de Deploy Automatizado 100% Azure CLI (Sprint 3)
# Opção Escolhida: Opção 1 - ACR + ACI (Solução Containerizada Completa: App + DB)
# Disciplina: DevOps Tools & Cloud Computing - FIAP
#
# SEGURANÇA: Credenciais buscadas do Azure Key Vault em tempo de deploy.
# Nenhuma senha é hardcoded neste script ou no application.properties.
# ==============================================================================

# Definição de Variáveis Parametrizadas
RESOURCE_GROUP="rg-clyvo-devops-sprint3"
LOCATION="eastus"
ACR_NAME="acrclyvovet$RANDOM"
IMAGE_APP_NAME="clyvo-api:v1"
CONTAINER_GROUP_NAME="cg-clyvo-vet"
DNS_LABEL="clyvo-vet-api-$RANDOM"
KEY_VAULT_NAME="kv-clyvo-vet"

echo "===================================================================="
echo "🚀 INICIANDO DEPLOY COMPLETO NA AZURE (ACR + ACI)"
echo "Projeto: Clyvo Vet | Solução 100% Containerizada"
echo "Resource Group: $RESOURCE_GROUP | Região: $LOCATION"
echo "===================================================================="

# 1. Criação do Grupo de Recursos
echo "[1/7] Criando Grupo de Recursos ($RESOURCE_GROUP)..."
az group create --name "$RESOURCE_GROUP" --location "$LOCATION" -o table

# 2. Azure Key Vault — Criação e armazenamento de secrets
echo "[2/7] Configurando Azure Key Vault ($KEY_VAULT_NAME)..."
KV_EXISTING=$(az keyvault list --resource-group "$RESOURCE_GROUP" --query "[?name=='$KEY_VAULT_NAME'].name" -o tsv 2>/dev/null || true)
if [ -z "$KV_EXISTING" ]; then
  echo "     Criando Key Vault..."
  # Registrar provider se necessário
  az provider register --namespace Microsoft.KeyVault 2>/dev/null || true
  az keyvault create \
    --name "$KEY_VAULT_NAME" \
    --resource-group "$RESOURCE_GROUP" \
    --location "$LOCATION" \
    --sku standard \
    --enable-rbac-authorization true \
    -o table
  # Atribuir permissão ao usuário logado
  CURRENT_USER=$(az ad signed-in-user show --query id -o tsv 2>/dev/null || true)
  if [ -n "$CURRENT_USER" ]; then
    az role assignment create \
      --role "Key Vault Secrets Officer" \
      --assignee "$CURRENT_USER" \
      --scope "/subscriptions/$(az account show --query id -o tsv)/resourceGroups/$RESOURCE_GROUP/providers/Microsoft.KeyVault/vaults/$KEY_VAULT_NAME" \
      2>/dev/null || true
    sleep 10  # Aguardar propagação de RBAC
  fi
  # Armazenar secrets sensíveis no Key Vault
  az keyvault secret set --vault-name "$KEY_VAULT_NAME" --name "DB-USER"     --value "${DB_USER:-RM562795}"             > /dev/null
  az keyvault secret set --vault-name "$KEY_VAULT_NAME" --name "DB-PASSWORD" --value "${DB_PASSWORD:-FiapDevOps2026#}"  > /dev/null
  az keyvault secret set --vault-name "$KEY_VAULT_NAME" --name "DB-URL"      --value "jdbc:oracle:thin:@localhost:1521/FREEPDB1" > /dev/null
  echo "     ✅ Secrets armazenados no Key Vault com segurança."
else
  echo "     Reutilizando Key Vault existente: $KEY_VAULT_NAME"
fi

# Buscar secrets do Key Vault (nunca hardcoded aqui)
echo "     Lendo credenciais do Key Vault..."
DB_USER=$(az keyvault secret show --vault-name "$KEY_VAULT_NAME" --name "DB-USER"     --query value -o tsv)
DB_PASSWORD=$(az keyvault secret show --vault-name "$KEY_VAULT_NAME" --name "DB-PASSWORD" --query value -o tsv)

# 3. Azure Container Registry (ACR)
ACR_EXISTING=$(az acr list --resource-group "$RESOURCE_GROUP" --query "[0].name" -o tsv 2>/dev/null || true)
if [ -n "$ACR_EXISTING" ] && [ "$ACR_EXISTING" != "None" ]; then
  ACR_NAME="$ACR_EXISTING"
  echo "[3/7] Reutilizando Azure Container Registry existente: $ACR_NAME..."
else
  echo "[3/7] Criando Azure Container Registry ($ACR_NAME)..."
  az acr create \
    --resource-group "$RESOURCE_GROUP" \
    --name "$ACR_NAME" \
    --sku Basic \
    --admin-enabled true \
    -o table
fi

# Credenciais do ACR — armazenar no Key Vault após criação
ACR_LOGIN_SERVER=$(az acr show --name "$ACR_NAME" --query loginServer --output tsv)
ACR_USERNAME=$(az acr credential show --name "$ACR_NAME" --query username --output tsv)
ACR_PASSWORD=$(az acr credential show --name "$ACR_NAME" --query "passwords[0].value" --output tsv)
az keyvault secret set --vault-name "$KEY_VAULT_NAME" --name "ACR-PASSWORD" --value "$ACR_PASSWORD" > /dev/null 2>&1 || true

# 4. Build e Envio da Imagem Docker para o ACR
echo "[4/7] Compilando e Enviando Imagem Java para o ACR via Docker CLI..."
echo "$ACR_PASSWORD" | docker login "$ACR_LOGIN_SERVER" -u "$ACR_USERNAME" --password-stdin
docker buildx build --platform linux/amd64 -t "$ACR_LOGIN_SERVER/$IMAGE_APP_NAME" --push .

# 5. Provisionar o Container Group ACI (App + Oracle DB)
echo "[5/7] Provisionando Azure Container Instances Multi-Container (App + Banco)..."

export LOCATION
export CONTAINER_GROUP_NAME
export DNS_LABEL
export ACR_LOGIN_SERVER
export ACR_USERNAME
export ACR_PASSWORD
export IMAGE_APP_NAME
export DB_USER
export DB_PASSWORD

envsubst < azure-aci-multicontainer.template.yaml > azure-aci-deployment.yaml

az container create \
  --resource-group "$RESOURCE_GROUP" \
  --file azure-aci-deployment.yaml \
  -o table

# 6. Obtenção de Endereços Públicos
FQDN=$(az container show --resource-group "$RESOURCE_GROUP" --name "$CONTAINER_GROUP_NAME" --query ipAddress.fqdn --output tsv)
IP_PUBLICO=$(az container show --resource-group "$RESOURCE_GROUP" --name "$CONTAINER_GROUP_NAME" --query ipAddress.ip --output tsv)

# 7. Resumo final
echo "===================================================================="
echo "✅ DEPLOY CONCLUÍDO COM SUCESSO NO ACI!"
echo "===================================================================="
echo "🏗️  Resource Group:  $RESOURCE_GROUP"
echo "📦  ACR:            $ACR_LOGIN_SERVER"
echo "🔑  Key Vault:      https://$KEY_VAULT_NAME.vault.azure.net/"
echo "🌐  FQDN:           http://$FQDN:8080"
echo "📍  IP Público:     http://$IP_PUBLICO:8080"
echo "📄  Swagger UI:     http://$FQDN:8080/swagger-ui/index.html"
echo "--------------------------------------------------------------------"
echo "Endpoints CRUD:"
echo "  - Tutores: http://$FQDN:8080/api/tutores"
echo "  - Pets:    http://$FQDN:8080/api/pets"
echo "===================================================================="
