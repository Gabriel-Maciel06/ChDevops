# 📋 Evidências de Persistência - CRUD Completo (App + Banco na Nuvem)

**Projeto:** Clyvo Vet API
**Sprint:** 3ª Sprint - DevOps Tools & Cloud Computing (Opção 1: ACR + ACI)
**Ambiente:** Azure Container Instances `cg-clyvo-vet` (East US) - containers `clyvo-api` + `clyvo-db`
**URL Base:** `http://clyvo-vet-api-13814.eastus.azurecontainer.io:8080`
**Data:** 2026-09-12

Cada operação da API foi seguida de um `SELECT` executado **dentro do container Oracle no ACI** com
`./consultar_banco_nuvem.sh` (a porta 1521 não é pública). Saídas reproduzidas sem edição.

---

## 0. Estado inicial do banco (logo após o deploy)

Tabelas criadas pelo `script_bd.sql` embutido na imagem `clyvo-db` e carga inicial de raças:

```
$ ./consultar_banco_nuvem.sh "SELECT id, nome, expectativa_vida FROM T_RACA"
        ID NOME                      EXPECTATIVA_VIDA
---------- ------------------------- ----------------
         1 Golden Retriever                        12
         2 Bulldog Francês                         10
         3 Gato Persa                              14
3 rows selected.

$ ./consultar_banco_nuvem.sh "SELECT COUNT(*) AS tutores FROM T_TUTOR"
   TUTORES
----------
         0
```

---

## 1. CREATE - `POST /api/tutores` (2 tutores) e `POST /api/pets` (2 pets)

```http
POST /api/tutores  →  201 Created
{"cpf":"11122233344","nome":"Gabriel Maciel","telefone":"(11) 98765-4321","email":"gabriel.maciel@clyvovet.com","quantidadePets":1}

POST /api/tutores  →  201 Created
{"cpf":"55566677788","nome":"Vitória Rodrigues","telefone":"(11) 91234-5678","email":"vitoria.rodrigues@clyvovet.com","quantidadePets":1}

POST /api/pets  →  201 Created
{"id":1,"nome":"Thor","dataNascimento":"2020-04-10","peso":34.5,"racaId":1,"racaNome":"Golden Retriever","tutorCpf":"11122233344","statusLongevidade":"Fase adulta madura. Monitoramento preventivo semestral."}

POST /api/pets  →  201 Created
{"id":2,"nome":"Luna","dataNascimento":"2017-08-20","peso":12.0,"racaId":2,"racaNome":"Bulldog Francês","tutorCpf":"55566677788","statusLongevidade":"Fase sênior. Check-up cardiorrespiratório trimestral."}
```

**Evidência no banco:**
```
$ ./consultar_banco_nuvem.sh "SELECT cpf, nome, telefone, qtd_pets FROM T_TUTOR ORDER BY cpf"
CPF            NOME                      TELEFONE           QTD_PETS
-------------- ------------------------- ---------------- ----------
11122233344    Gabriel Maciel            (11) 98765-4321           1
55566677788    Vitória Rodrigues         (11) 91234-5678           1
2 rows selected.

$ ./consultar_banco_nuvem.sh "SELECT id, nome, peso, raca_id, tutor_cpf FROM T_PET ORDER BY id"
        ID NOME                            PESO    RACA_ID TUTOR_CPF
---------- ------------------------- ---------- ---------- --------------
         1 Thor                            34.5          1 11122233344
         2 Luna                              12          2 55566677788
2 rows selected.
```
> ✔️ 2 linhas significativas em `T_TUTOR` e 2 em `T_PET`, com FK `tutor_cpf` → `T_TUTOR`.

---

## 2. READ - `GET /api/tutores`, `GET /api/pets/2`, `GET /api/tutores/{cpf}/pets`

```json
GET /api/tutores  →  200 OK  (totalElements: 2)
{"content":[
  {"cpf":"11122233344","nome":"Gabriel Maciel","telefone":"(11) 98765-4321","email":"gabriel.maciel@clyvovet.com","quantidadePets":1},
  {"cpf":"55566677788","nome":"Vitória Rodrigues","telefone":"(11) 91234-5678","email":"vitoria.rodrigues@clyvovet.com","quantidadePets":1}
], "totalElements":2, "totalPages":1}

GET /api/pets/2  →  200 OK  (HATEOAS)
{"id":2,"nome":"Luna","dataNascimento":"2017-08-20","peso":12.0,"racaId":2,"racaNome":"Bulldog Francês",
 "tutorCpf":"55566677788","statusLongevidade":"Fase sênior. Check-up cardiorrespiratório trimestral.",
 "_links":{"self":{"href":".../api/pets/2"},"lista-pets":{"href":".../api/pets"}}}

GET /api/tutores/11122233344/pets  →  200 OK
[{"id":1,"nome":"Thor","peso":34.5,"raca":{"id":1,"nome":"Golden Retriever","propensaoDoenca":"Displasia coxofemoral e cardiomiopatia", ...},
  "tutor":{"cpf":"11122233344","nome":"Gabriel Maciel", ...},"statusLongevidade":"Fase adulta madura. Monitoramento preventivo semestral."}]
```
> ✔️ Consulta paginada, por id e pelo relacionamento tutor → pets.

---

## 3. UPDATE - `PUT /api/pets/1` e `PUT /api/tutores/55566677788`

```http
PUT /api/pets/1  →  200 OK   (peso 34.5 → 33.8, novo parecer)
{"id":1,"nome":"Thor","dataNascimento":"2020-04-10","peso":33.8,"racaId":1,"racaNome":"Golden Retriever","tutorCpf":"11122233344","statusLongevidade":"Peso otimizado. Longevidade estimada em 13 anos."}

PUT /api/tutores/55566677788  →  200 OK   (nome, telefone e qtd_pets)
{"cpf":"55566677788","nome":"Vitória Rodrigues Martins","telefone":"(11) 99999-0002","email":"vitoria.rodrigues@clyvovet.com","quantidadePets":2}
```

**Evidência no banco:**
```
$ ./consultar_banco_nuvem.sh "SELECT id, nome, peso, status_longevidade FROM T_PET WHERE id = 1"
        ID NOME                            PESO STATUS_LONGEVIDADE
---------- ------------------------- ---------- ---------------------------------------------
         1 Thor                            33.8 Peso otimizado. Longevidade estimada em 13 anos.
1 row selected.

$ ./consultar_banco_nuvem.sh "SELECT cpf, nome, telefone, qtd_pets FROM T_TUTOR WHERE cpf = '55566677788'"
CPF            NOME                      TELEFONE           QTD_PETS
-------------- ------------------------- ---------------- ----------
55566677788    Vitória Rodrigues Martins (11) 99999-0002           2
1 row selected.
```
> ✔️ Alterações persistidas nas duas tabelas.

---

## 4. DELETE - `DELETE /api/pets/2` e `DELETE /api/tutores/55566677788`

```
DELETE /api/pets/2               →  HTTP 204
DELETE /api/tutores/55566677788  →  HTTP 204
```

**Evidência no banco:**
```
$ ./consultar_banco_nuvem.sh "SELECT id, nome, tutor_cpf FROM T_PET ORDER BY id"
        ID NOME                      TUTOR_CPF
---------- ------------------------- --------------
         1 Thor                      11122233344
1 row selected.

$ ./consultar_banco_nuvem.sh "SELECT cpf, nome FROM T_TUTOR ORDER BY cpf"
CPF            NOME
-------------- -------------------------
11122233344    Gabriel Maciel
1 row selected.
```

**Confirmação pela API:**
```
GET /api/pets/2               →  HTTP 404
GET /api/tutores/55566677788  →  HTTP 404
```
> ✔️ Registros removidos do Oracle na nuvem e inexistentes para a API.

---

## 🏗️ Infraestrutura utilizada

| Recurso | Valor |
|---------|-------|
| **Resource Group** | `rg-clyvo-devops-sprint3` (East US) |
| **ACR** | `acrclyvovet18809.azurecr.io` - imagens `clyvo-api:v1` e `clyvo-db:v1` |
| **Key Vault** | `kv-clyvo-vet` - `DB-USER`, `DB-PASSWORD`, `DB-URL`, `ACR-PASSWORD` |
| **Container Group** | `cg-clyvo-vet` - `clyvo-db` (Oracle 23c Free, 1521 interna) + `clyvo-api` (Spring Boot, 8080 pública) |
| **FQDN / IP** | `clyvo-vet-api-13814.eastus.azurecontainer.io` / `52.170.162.183` |

## 🔐 Segurança
- Credenciais somente no Azure Key Vault e em variáveis de ambiente do ACI; nada no código ou no repositório.
- Container da API executa como usuário não-root (`appuser`).
- Porta 1521 fechada para a internet; SELECTs feitos via `az container exec` dentro do container.

---

*Equipe: Gabriel Maciel (RM562795), Vitória Rodrigues Martins (RM565160), Augusto Bonomo Júnior (RM565155), Thomas Fontes (RM562254), Matheus Pereira Molina (RM563399)*
