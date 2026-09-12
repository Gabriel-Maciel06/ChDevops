#!/bin/bash
# ==============================================================================
# Clyvo Vet - Consulta SQL direta no Oracle que roda dentro do ACI (nuvem)
# ------------------------------------------------------------------------------
# A porta 1521 NÃO é exposta na internet (segurança). Este script usa
# `az container exec` para abrir o SQL*Plus DENTRO do container clyvo-db e
# executar o SQL informado no schema da aplicação, sem digitar senha na tela
# (as credenciais já existem como variáveis de ambiente do container).
#
# Uso:
#   ./consultar_banco_nuvem.sh "SELECT * FROM T_TUTOR"
#   ./consultar_banco_nuvem.sh "SELECT id, nome, peso, tutor_cpf FROM T_PET"
#   ./consultar_banco_nuvem.sh                 # abre um SQL*Plus interativo
# ==============================================================================
set -euo pipefail

RESOURCE_GROUP="${RESOURCE_GROUP:-rg-clyvo-devops-sprint3}"
CONTAINER_GROUP_NAME="${CONTAINER_GROUP_NAME:-cg-clyvo-vet}"
DB_CONTAINER="clyvo-db"

# Comando executado dentro do container (a senha nunca sai do container)
CONNECT='sqlplus -s ${APP_USER}/${APP_USER_PASSWORD}@localhost/${ORACLE_DATABASE:-FREEPDB1}'

if [ $# -eq 0 ]; then
  echo "🔎 Abrindo SQL*Plus interativo no container $DB_CONTAINER (digite EXIT para sair)..."
  INNER='sqlplus ${APP_USER}/${APP_USER_PASSWORD}@localhost/${ORACLE_DATABASE:-FREEPDB1}'
else
  SQL="$*"
  case "$SQL" in *\;) ;; *) SQL="$SQL;";; esac
  INNER="printf '%s\n' 'SET PAGESIZE 200 LINESIZE 220 FEEDBACK ON' 'COLUMN nome FORMAT A25' 'COLUMN email FORMAT A32' 'COLUMN telefone FORMAT A16' 'COLUMN status_longevidade FORMAT A45' \"$SQL\" 'EXIT' | $CONNECT"
fi

# `az container exec` divide o comando por espaços; por isso o comando real é
# transportado em base64 e reconstruído dentro do container com ${IFS}.
B64=$(printf '%s' "$INNER" | base64 | tr -d '\n')
az container exec \
  --resource-group "$RESOURCE_GROUP" \
  --name "$CONTAINER_GROUP_NAME" \
  --container-name "$DB_CONTAINER" \
  --exec-command "bash -c eval\${IFS}\"\$(echo\${IFS}$B64|base64\${IFS}-d)\""
