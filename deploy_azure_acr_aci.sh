#!/bin/bash
set -euo pipefail

# ==============================================================================
# Clyvo Vet - Deploy Automatizado 100% Azure CLI (Sprint 3 - DevOps Tools & Cloud)
# Opção 1: ACR + ACI - Solução Containerizada Completa (App + Banco de Dados)
#
# O que este script faz:
#   1. Resource Group
#   2. Azure Key Vault (guarda DB_USER, DB_PASSWORD, DB_URL, ACR-PASSWORD)
#   3. Azure Container Registry (ACR)
#   4. Build + push das DUAS imagens (clyvo-api e clyvo-db) para o ACR
#   5. Azure Container Instances (ACI) multi-container: clyvo-db + clyvo-api
#   6. Aguarda a API responder e imprime as URLs
#
# SEGURANÇA: nenhuma senha está neste arquivo. Na primeira execução informe
#   export DB_USER=<usuario>  export DB_PASSWORD='<senha forte>'
# (ou use um arquivo .env, ignorado pelo git). As execuções seguintes leem do Key Vault.
# ==============================================================================

# Carrega .env local se existir (nunca commitado)
if [ -f .env ]; then set -a; . ./.env; set +a; fi

RESOURCE_GROUP="${RESOURCE_GROUP:-rg-clyvo-devops-sprint3}"
LOCATION="${LOCATION:-eastus}"
KEY_VAULT_NAME="${KEY_VAULT_NAME:-kv-clyvo-vet}"
ACR_NAME="${ACR_NAME:-acrclyvovet$RANDOM}"
CONTAINER_GROUP_NAME="cg-clyvo-vet"
DNS_LABEL="${DNS_LABEL:-clyvo-vet-api-$RANDOM}"
IMAGE_APP_NAME="clyvo-api:v1"
IMAGE_DB_NAME="clyvo-db:v1"

echo "===================================================================="
echo "🚀 DEPLOY COMPLETO NA AZURE (ACR + ACI) - Clyvo Vet"
echo "Resource Group: $RESOURCE_GROUP | Região: $LOCATION"
echo "===================================================================="

# ------------------------------------------------------------------------------
# 1. Resource Group
# ------------------------------------------------------------------------------
echo "[1/6] Criando Resource Group ($RESOURCE_GROUP)..."
az group create --name "$RESOURCE_GROUP" --location "$LOCATION" -o table

# ------------------------------------------------------------------------------
# 2. Azure Key Vault - cofre de credenciais
# ------------------------------------------------------------------------------
echo "[2/6] Configurando Azure Key Vault ($KEY_VAULT_NAME)..."
KV_EXISTING=$(az keyvault list --resource-group "$RESOURCE_GROUP" --query "[?name=='$KEY_VAULT_NAME'].name" -o tsv 2>/dev/null || true)
if [ -z "$KV_EXISTING" ]; then
  if [ -z "${DB_USER:-}" ] || [ -z "${DB_PASSWORD:-}" ]; then
    echo "❌ ERRO: Defina DB_USER e DB_PASSWORD antes de executar (primeira execução)."
    echo "   Exemplo: export DB_USER=clyvo_app && export DB_PASSWORD='SenhaForte#2026'"
    exit 1
  fi
  echo "     Criando Key Vault..."
  az provider register --namespace Microsoft.KeyVault -o none 2>/dev/null || true
  az keyvault create \
    --name "$KEY_VAULT_NAME" \
    --resource-group "$RESOURCE_GROUP" \
    --location "$LOCATION" \
    --sku standard \
    --enable-rbac-authorization true \
    -o table
  CURRENT_USER=$(az ad signed-in-user show --query id -o tsv 2>/dev/null || true)
  if [ -n "$CURRENT_USER" ]; then
    az role assignment create \
      --role "Key Vault Secrets Officer" \
      --assignee "$CURRENT_USER" \
      --scope "/subscriptions/$(az account show --query id -o tsv)/resourceGroups/$RESOURCE_GROUP/providers/Microsoft.KeyVault/vaults/$KEY_VAULT_NAME" \
      -o none 2>/dev/null || true
    echo "     Aguardando propagação da permissão RBAC (30s)..."
    sleep 30
  fi
  az keyvault secret set --vault-name "$KEY_VAULT_NAME" --name "DB-USER"     --value "$DB_USER"     -o none
  az keyvault secret set --vault-name "$KEY_VAULT_NAME" --name "DB-PASSWORD" --value "$DB_PASSWORD" -o none
  az keyvault secret set --vault-name "$KEY_VAULT_NAME" --name "DB-URL"      --value "jdbc:oracle:thin:@localhost:1521/FREEPDB1" -o none
  echo "     ✅ Secrets armazenados no Key Vault."
else
  echo "     Reutilizando Key Vault existente: $KEY_VAULT_NAME"
fi

echo "     Lendo credenciais do Key Vault..."
DB_USER=$(az keyvault secret show --vault-name "$KEY_VAULT_NAME" --name "DB-USER"     --query value -o tsv)
DB_PASSWORD=$(az keyvault secret show --vault-name "$KEY_VAULT_NAME" --name "DB-PASSWORD" --query value -o tsv)
DB_URL=$(az keyvault secret show --vault-name "$KEY_VAULT_NAME" --name "DB-URL" --query value -o tsv)

# ------------------------------------------------------------------------------
# 3. Azure Container Registry (ACR)
# ------------------------------------------------------------------------------
ACR_EXISTING=$(az acr list --resource-group "$RESOURCE_GROUP" --query "[0].name" -o tsv 2>/dev/null || true)
if [ -n "$ACR_EXISTING" ] && [ "$ACR_EXISTING" != "None" ]; then
  ACR_NAME="$ACR_EXISTING"
  echo "[3/6] Reutilizando Azure Container Registry existente: $ACR_NAME"
else
  echo "[3/6] Criando Azure Container Registry ($ACR_NAME)..."
  az acr create \
    --resource-group "$RESOURCE_GROUP" \
    --name "$ACR_NAME" \
    --sku Basic \
    --admin-enabled true \
    -o table
fi
ACR_LOGIN_SERVER=$(az acr show --name "$ACR_NAME" --query loginServer -o tsv)
ACR_USERNAME=$(az acr credential show --name "$ACR_NAME" --query username -o tsv)
ACR_PASSWORD=$(az acr credential show --name "$ACR_NAME" --query "passwords[0].value" -o tsv)
az keyvault secret set --vault-name "$KEY_VAULT_NAME" --name "ACR-PASSWORD" --value "$ACR_PASSWORD" -o none 2>/dev/null || true

# ------------------------------------------------------------------------------
# 4. Build e push das imagens (App + Banco) para o ACR
#    ACI executa linux/amd64; em Macs Apple Silicon o buildx faz cross-build.
# ------------------------------------------------------------------------------
echo "[4/6] Build e push das imagens para o ACR ($ACR_LOGIN_SERVER)..."
echo "$ACR_PASSWORD" | docker login "$ACR_LOGIN_SERVER" -u "$ACR_USERNAME" --password-stdin

echo "     -> Imagem da aplicação: $IMAGE_APP_NAME (Dockerfile)"
docker buildx build --platform linux/amd64 -f Dockerfile    -t "$ACR_LOGIN_SERVER/$IMAGE_APP_NAME" --push .

echo "     -> Imagem do banco Oracle 23c Free + DDL: $IMAGE_DB_NAME (db/Dockerfile)"
docker buildx build --platform linux/amd64 -f db/Dockerfile -t "$ACR_LOGIN_SERVER/$IMAGE_DB_NAME"  --push .

echo "     Imagens publicadas no ACR:"
az acr repository list --name "$ACR_NAME" -o table

# ------------------------------------------------------------------------------
# 5. Azure Container Instances - grupo multi-container (clyvo-db + clyvo-api)
# ------------------------------------------------------------------------------
echo "[5/6] Provisionando ACI multi-container ($CONTAINER_GROUP_NAME)..."
export LOCATION CONTAINER_GROUP_NAME DNS_LABEL ACR_LOGIN_SERVER ACR_USERNAME ACR_PASSWORD \
       IMAGE_APP_NAME IMAGE_DB_NAME DB_USER DB_PASSWORD DB_URL

# Gera o YAML final (com credenciais) - arquivo ignorado pelo git
envsubst < azure-aci-multicontainer.template.yaml > azure-aci-deployment.yaml

az container create \
  --resource-group "$RESOURCE_GROUP" \
  --file azure-aci-deployment.yaml \
  --query "{nome:name, status:provisioningState, fqdn:ipAddress.fqdn, ip:ipAddress.ip}" \
  -o table

rm -f azure-aci-deployment.yaml   # não deixar credenciais em disco
echo "     Containers do grupo:"
az container show --resource-group "$RESOURCE_GROUP" --name "$CONTAINER_GROUP_NAME" \
  --query "containers[].{container:name, imagem:image, estado:instanceView.currentState.state}" -o table

# ------------------------------------------------------------------------------
# 6. Endereços públicos e verificação de saúde
# ------------------------------------------------------------------------------
FQDN=$(az container show --resource-group "$RESOURCE_GROUP" --name "$CONTAINER_GROUP_NAME" --query ipAddress.fqdn -o tsv)
IP_PUBLICO=$(az container show --resource-group "$RESOURCE_GROUP" --name "$CONTAINER_GROUP_NAME" --query ipAddress.ip -o tsv)
BASE_URL="http://$FQDN:8080"

echo "[6/6] Aguardando o Oracle inicializar e a API subir (pode levar de 2 a 5 min)..."
for i in $(seq 1 60); do
  if curl -s -o /dev/null -m 5 -w "%{http_code}" "$BASE_URL/api/tutores" 2>/dev/null | grep -q "200"; then
    echo "     ✅ API respondendo em $BASE_URL"
    break
  fi
  printf "."
  sleep 10
  if [ "$i" -eq 60 ]; then
    echo; echo "⚠️  A API ainda não respondeu. Verifique os logs:"
    echo "   az container logs -g $RESOURCE_GROUP -n $CONTAINER_GROUP_NAME --container-name clyvo-api"
  fi
done

echo "===================================================================="
echo "✅ DEPLOY CONCLUÍDO (ACR + ACI)"
echo "===================================================================="
echo "🏗️  Resource Group:  $RESOURCE_GROUP"
echo "📦  ACR:             $ACR_LOGIN_SERVER  (clyvo-api:v1, clyvo-db:v1)"
echo "🔑  Key Vault:       https://$KEY_VAULT_NAME.vault.azure.net/"
echo "🐳  ACI:             $CONTAINER_GROUP_NAME (clyvo-db + clyvo-api)"
echo "🌐  FQDN:            $BASE_URL"
echo "📍  IP Público:      http://$IP_PUBLICO:8080"
echo "📄  Swagger UI:      $BASE_URL/swagger-ui/index.html"
echo "--------------------------------------------------------------------"
echo "Próximos passos:"
echo "  ./testes_crud_core.sh $BASE_URL"
echo "  ./consultar_banco_nuvem.sh \"SELECT * FROM T_TUTOR\""
echo "===================================================================="
