#!/bin/bash
set -e

# ==============================================================================
# Clyvo Vet - Script de Limpeza de Recursos na Azure (Economia de Créditos)
# ==============================================================================

RESOURCE_GROUP="rg-clyvo-devops-sprint3"

echo "===================================================================="
echo "⚠️  REMOVENDO GRUPO DE RECURSOS NA AZURE: $RESOURCE_GROUP"
echo "Todos os containers (ACI) e registros (ACR) serão destruídos."
echo "===================================================================="

az group delete --name "$RESOURCE_GROUP" --yes --no-wait

echo "Solicitação de exclusão enviada com sucesso!"
echo "O Azure está desalocando os recursos em segundo plano."
echo "===================================================================="
