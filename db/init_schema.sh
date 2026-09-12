#!/bin/bash
# ==============================================================================
# Executado pela imagem gvenzl/oracle-free na PRIMEIRA inicialização do banco.
# Os *.sql em /container-entrypoint-initdb.d rodariam como SYS no CDB root;
# por isso este .sh conecta explicitamente no schema da aplicação (APP_USER)
# dentro do PDB FREEPDB1 e aplica o DDL oficial + carga inicial.
# ==============================================================================
set -e
PDB="${ORACLE_DATABASE:-FREEPDB1}"
echo "[clyvo-db] Aplicando script_bd.sql e seed_dados.sql no schema ${APP_USER}@${PDB}..."
sqlplus -s "${APP_USER}/${APP_USER_PASSWORD}@localhost/${PDB}" <<SQL
WHENEVER SQLERROR EXIT SQL.SQLCODE
SET ECHO OFF FEEDBACK ON
@/opt/clyvo/sql/01_script_bd.sql
@/opt/clyvo/sql/02_seed_dados.sql
EXIT
SQL
echo "[clyvo-db] Schema CORE (T_RACA, T_TUTOR, T_PET) criado com sucesso."
