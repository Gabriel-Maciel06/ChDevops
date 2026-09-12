# 🎬 Roteiro de Gravação do Vídeo - DevOps Tools & Cloud Computing
**Disciplina:** DevOps Tools & Cloud Computing - 3ª Sprint (FIAP)
**Projeto:** Clyvo Vet - Solução 100% Containerizada em Nuvem (Microsoft Azure)
**Opção Escolhida:** **Opção 1: ACR + ACI**

> Regras do edital que o vídeo precisa cumprir: mínimo 720p, voz clara (sem legendas), **começar pelo clone do GitHub**, seguir **exatamente** o README, mostrar a **criação dos recursos na Azure**, e **sem cortes** durante os testes do CRUD e a persistência no banco (cada operação evidenciada por SELECT).

## ✅ Antes de gravar (checklist)
- [ ] `az login` feito e conta *Azure for Students* selecionada (`az account show`).
- [ ] Docker Desktop aberto.
- [ ] Nenhum recurso antigo no ar: `./destroy_azure.sh` e aguardar o resource group sumir (`az group exists -n rg-clyvo-devops-sprint3` → `false`). Se o Key Vault ficar em *soft-delete*, purgue: `az keyvault purge --name kv-clyvo-vet --location eastus`.
- [ ] Pasta limpa para o clone (ex.: `~/Desktop/demo`).
- [ ] Dois terminais abertos lado a lado: **Terminal A** (API/cURL) e **Terminal B** (banco/SQL).
- [ ] Portal Azure aberto numa aba do navegador (para mostrar os recursos criados).
- [ ] Definir as credenciais no terminal **antes** de começar a gravar (a senha não deve aparecer na tela):
  ```bash
  export DB_USER=clyvo_app
  export DB_PASSWORD='<senha forte>'
  ```

---

## 1. 🎬 Abertura e clone do repositório (0:00 - 1:00)
**Fala:** *"Olá professor! Somos o grupo Clyvo Vet e esta é a entrega da 3ª Sprint de DevOps Tools & Cloud Computing. Escolhemos a Opção 1, ACR + ACI, com aplicação e banco de dados totalmente containerizados. Como pede o edital, começamos pelo clone limpo do repositório."*
```bash
git clone https://github.com/Gabriel-Maciel06/ChDevops.git
cd ChDevops
ls -la
```
Mostre rapidamente: `README.md`, `script_bd.sql`, `Dockerfile`, `db/Dockerfile`, `deploy_azure_acr_aci.sh`, `azure-aci-multicontainer.template.yaml`.

## 2. 🗺️ Arquitetura (1:00 - 2:00)
Abra `clyvo_devops_architecture.png` (ou a seção 3 do README).
**Fala:** *"A equipe faz o build de duas imagens Docker: a API Spring Boot e o Oracle 23c Free com o DDL embutido. As duas vão para o Azure Container Registry. O Azure Container Instances executa as duas num mesmo grupo de containers, que compartilham a rede localhost: a API fala com o banco pela porta 1521 interna e só a porta 8080 é pública. As credenciais ficam no Azure Key Vault e o container da API roda com o usuário não-root `appuser`."*

## 3. 🚀 Provisionamento 100% Azure CLI (2:00 - 8:00)
```bash
chmod +x *.sh
./deploy_azure_acr_aci.sh
```
**Fala, enquanto o script roda:** *"Todos os recursos são criados via Azure CLI: o resource group, o Key Vault que recebe usuário e senha do banco, o Container Registry, o build e push das duas imagens e, por fim, o grupo de containers no ACI a partir do template YAML."*

Enquanto o Oracle inicializa (2 a 5 min), vá ao **Portal Azure** e mostre: o resource group, o ACR com os repositórios `clyvo-api` e `clyvo-db`, o Key Vault com os 4 secrets e o container group `cg-clyvo-vet` com os dois containers *Running*. Volte ao terminal e mostre o resumo final com o FQDN.

Guarde a URL:
```bash
export API=http://<FQDN>:8080
```
Abra no navegador `$API/swagger-ui/index.html` e mostre os endpoints de tutores e pets.

## 4. 🧪 CRUD nas duas tabelas com evidência no banco - SEM CORTES (8:00 - 16:00)
**Fala:** *"Agora o CRUD completo nas duas tabelas CORE, T_TUTOR e T_PET, relacionadas 1 para N. Após cada operação mostramos o SELECT direto no Oracle que roda dentro do ACI."*

No **Terminal B**, mostre o estado inicial do banco (tabelas criadas pelo `script_bd.sql` e raças da carga inicial):
```bash
./consultar_banco_nuvem.sh "SELECT table_name FROM user_tables"
./consultar_banco_nuvem.sh "SELECT * FROM T_RACA"
./consultar_banco_nuvem.sh "SELECT * FROM T_TUTOR"
```

No **Terminal A**, rode o teste em modo pausado. Ele para após cada etapa para você evidenciar no Terminal B:
```bash
PAUSA=1 ./testes_crud_core.sh $API
```

| Etapa do script (Terminal A) | Evidência no banco (Terminal B) |
| :--- | :--- |
| **[1-2] CREATE** - 2 tutores e 2 pets (Thor e Luna) | `./consultar_banco_nuvem.sh "SELECT * FROM T_TUTOR"` <br> `./consultar_banco_nuvem.sh "SELECT id, nome, peso, raca_id, tutor_cpf FROM T_PET"` |
| **[3-4] READ** - listagens, busca por id com HATEOAS e insight preditivo | (opcional) repetir os SELECTs |
| **[5-6] UPDATE** - peso do Thor 34.5 → 33.8; telefone/qtd pets da Vitória | `./consultar_banco_nuvem.sh "SELECT id, nome, peso, status_longevidade FROM T_PET"` <br> `./consultar_banco_nuvem.sh "SELECT cpf, nome, telefone, qtd_pets FROM T_TUTOR"` |
| **[7-8] DELETE** - pet Luna e tutora Vitória | `./consultar_banco_nuvem.sh "SELECT * FROM T_PET"` <br> `./consultar_banco_nuvem.sh "SELECT * FROM T_TUTOR"` |
| **[9] CONFIRMAÇÃO** - GET retorna 404 | - |

**Fala nos SELECTs:** *"Aqui, direto no banco Oracle na nuvem, o registro inserido / o peso atualizado / o registro removido."*

Se preferir demonstrar manualmente no Swagger em vez do script, use os mesmos payloads do README (seção 5) e os mesmos SELECTs.

## 5. 🧹 Encerramento (16:00 - 17:00)
```bash
./destroy_azure.sh
```
**Fala:** *"Para encerrar, removemos o resource group inteiro via CLI, garantindo controle de custos. Atendemos todos os requisitos: ACR + ACI criados por Azure CLI, aplicação e banco containerizados, container da API sem privilégios de root, DDL comentado, credenciais no Key Vault e CRUD completo nas duas tabelas com evidência de persistência no banco em nuvem. Obrigado!"*

---

## ⚠️ Erros comuns e como contornar na hora
| Sintoma | Causa provável | Solução |
| :--- | :--- | :--- |
| `Defina DB_USER e DB_PASSWORD` | Variáveis não exportadas no terminal | `export DB_USER=... DB_PASSWORD=...` e rode de novo |
| `az keyvault create` falha com nome já existente | Key Vault antigo em soft-delete | `az keyvault purge --name kv-clyvo-vet --location eastus` |
| API não responde após 10 min | Oracle ainda subindo ou senha inválida | `az container logs -g rg-clyvo-devops-sprint3 -n cg-clyvo-vet --container-name clyvo-db` |
| `POST /api/pets` retorna 404 "Tutor não encontrado" | Tutor não foi criado antes | crie o tutor primeiro (o script já faz na ordem certa) |
| `POST /api/pets` retorna 404 "Raça não encontrada" | `racaId` inexistente | use 1, 2 ou 3 (seed) ou omita o campo |
