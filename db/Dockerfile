# ==============================================================================
# Clyvo Vet - Imagem do Banco de Dados (Oracle Database 23c Free) para ACR/ACI
# ------------------------------------------------------------------------------
# Estende a imagem oficial gvenzl/oracle-free e embute o DDL oficial
# (script_bd.sql) + carga inicial (db/seed_dados.sql), executados uma única vez
# na primeira inicialização do banco, dentro do schema da aplicação (APP_USER).
# Nenhuma credencial é gravada na imagem: usuário e senha chegam por variáveis
# de ambiente (ORACLE_PASSWORD, APP_USER, APP_USER_PASSWORD) em tempo de execução.
# ==============================================================================
FROM gvenzl/oracle-free:23-slim-faststart

# SQL fica FORA de /container-entrypoint-initdb.d (senão rodaria como SYS no CDB);
# apenas o .sh é registrado lá e ele conecta no schema correto.
# (A imagem base já roda como usuário não-root 'oracle'; COPY cria os diretórios.)
COPY --chown=oracle:oinstall            script_bd.sql     /opt/clyvo/sql/01_script_bd.sql
COPY --chown=oracle:oinstall            db/seed_dados.sql /opt/clyvo/sql/02_seed_dados.sql
COPY --chown=oracle:oinstall --chmod=755 db/init_schema.sh /container-entrypoint-initdb.d/10_init_schema.sh

EXPOSE 1521
