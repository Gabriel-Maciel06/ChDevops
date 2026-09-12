# 📋 Evidências de Persistência de Dados — CRUD Completo

**Projeto:** Clyvo Vet API  
**Sprint:** 3ª Sprint — DevOps Tools & Cloud Computing  
**Ambiente:** Azure Container Instances (ACI) — East US  
**URL Base:** `http://clyvo-vet-api-29514.eastus.azurecontainer.io:8080`  
**Data da evidência:** 2026-09-12  

---

> ⚠️ **Nota de versão:** estas evidências foram coletadas no deploy inicial (v1) de 12/09/2026. Nessa versão o campo `statusLongevidade` ainda não era persistido (aparece `null`) e o teste cobria apenas parte do CRUD de tutores. A versão atual do código persiste o parecer, expõe `PUT`/`DELETE` de tutores e o script `testes_crud_core.sh` cobre as duas tabelas. As evidências definitivas, com SELECT no banco após cada operação (`consultar_banco_nuvem.sh`), estão no vídeo da entrega.

## ✅ CRUD-1 — CREATE (POST) — Tutor

**Requisição:**
```http
POST /api/tutores
Content-Type: application/json

{
  "cpf": "99988877766",
  "nome": "Thomas Fontes",
  "telefone": "(11) 97777-0001",
  "email": "thomas.fontes@clyvovet.com",
  "quantidadePets": 1
}
```

**Resposta `201 Created`:**
```json
{
  "cpf": "99988877766",
  "nome": "Thomas Fontes",
  "telefone": "(11) 97777-0001",
  "email": "thomas.fontes@clyvovet.com",
  "quantidadePets": 1
}
```
> ✔️ **Dado persistido no Oracle FREEPDB1 — tabela `T_TUTOR`**

---

## ✅ CRUD-2 — CREATE (POST) — Pet

**Requisição:**
```http
POST /api/pets
Content-Type: application/json

{
  "nome": "Bolt",
  "dataNascimento": "2021-06-15",
  "peso": 28.3,
  "racaId": 1,
  "tutorCpf": "99988877766",
  "statusLongevidade": "Adulto jovem. Longevidade estimada 12 anos."
}
```

**Resposta `201 Created`:**
```json
{
  "id": 3,
  "nome": "Bolt",
  "dataNascimento": "2021-06-15",
  "peso": 28.3,
  "tutorCpf": "99988877766",
  "statusLongevidade": null
}
```
> ✔️ **Pet criado com ID auto-gerado = 3 — tabela `T_PET`**

---

## ✅ CRUD-3 — READ ALL (GET) — Tutores

**Requisição:**
```http
GET /api/tutores
```

**Resposta `200 OK` — 3 tutores persistidos no banco:**
```json
{
  "content": [
    {
      "cpf": "11122233344",
      "nome": "Gabriel Maciel",
      "telefone": "(11) 98765-4321",
      "email": "gabriel.maciel@clyvovet.com",
      "quantidadePets": 1
    },
    {
      "cpf": "55566677788",
      "nome": "Vitória Rodrigues",
      "telefone": "(11) 91234-5678",
      "email": "vitoria.rodrigues@clyvovet.com",
      "quantidadePets": 2
    },
    {
      "cpf": "99988877766",
      "nome": "Thomas Fontes",
      "telefone": "(11) 97777-0001",
      "email": "thomas.fontes@clyvovet.com",
      "quantidadePets": 1
    }
  ],
  "totalElements": 3,
  "totalPages": 1
}
```
> ✔️ **3 registros persistidos e recuperados com paginação**

---

## ✅ CRUD-4 — READ ALL (GET) — Pets

**Requisição:**
```http
GET /api/pets
```

**Resposta `200 OK` — 2 pets persistidos no banco:**
```json
{
  "content": [
    {
      "id": 1,
      "nome": "Thor",
      "dataNascimento": "2020-04-10",
      "peso": 33.8,
      "tutorCpf": "11122233344",
      "statusLongevidade": null
    },
    {
      "id": 3,
      "nome": "Bolt",
      "dataNascimento": "2021-06-15",
      "peso": 28.3,
      "tutorCpf": "99988877766",
      "statusLongevidade": null
    }
  ],
  "totalElements": 2,
  "totalPages": 1
}
```
> ✔️ **2 pets persistidos e recuperados (id=2 foi deletado anteriormente)**

---

## ✅ CRUD-5 — UPDATE (PUT) — Atualização de Pet

**Requisição:**
```http
PUT /api/pets/3
Content-Type: application/json

{
  "nome": "Bolt",
  "dataNascimento": "2021-06-15",
  "peso": 26.0,
  "racaId": 1,
  "tutorCpf": "99988877766",
  "statusLongevidade": "Peso ajustado com dieta. Longevidade estimada 13 anos."
}
```

**Resposta `200 OK` — peso atualizado de 28.3 → 26.0:**
```json
{
  "id": 3,
  "nome": "Bolt",
  "dataNascimento": "2021-06-15",
  "peso": 26.0,
  "tutorCpf": "99988877766",
  "statusLongevidade": null
}
```
> ✔️ **Registro atualizado no banco — peso de 28.3 → 26.0 kg**

---

## ✅ CRUD-6 — DELETE (DELETE) — Remoção de Pet

**Requisição:**
```http
DELETE /api/pets/3
```

**Resposta:**
```
HTTP/1.1 204 No Content
Date: Sat, 12 Sep 2026 23:07:09 GMT
```
> ✔️ **HTTP 204 — Registro removido com sucesso**

---

## ✅ CRUD-7 — Confirmação de Exclusão (GET após DELETE)

**Requisição:**
```http
GET /api/pets/3
```

**Resposta `404 Not Found`:**
```
Pet não encontrado com id 3
```
> ✔️ **Confirmado: o Pet id=3 foi de fato excluído do banco Oracle**

---

## 🏗️ Infraestrutura utilizada

| Recurso | Valor |
|---------|-------|
| **Resource Group** | `rg-clyvo-devops-sprint3` |
| **ACR** | `acrclyvovet18809.azurecr.io` |
| **Key Vault** | `kv-clyvo-vet` |
| **Container Group** | `cg-clyvo-vet` (East US) |
| **IP Público** | `20.242.131.163` |
| **FQDN** | `clyvo-vet-api-29514.eastus.azurecontainer.io` |
| **Banco de Dados** | Oracle 23c Free — `FREEPDB1` |
| **Aplicação** | Spring Boot 3.x — Hibernate JPA |

---

## 🔐 Segurança implementada

- Credenciais armazenadas no **Azure Key Vault** (`kv-clyvo-vet`)
- Variáveis de ambiente injetadas no ACI em tempo de deploy
- `application.properties` **sem nenhum fallback hardcoded** para dados sensíveis
- Senha nunca exposta no código-fonte ou logs

---

*Evidências coletadas em: 2026-09-12 | Equipe: Gabriel Maciel (RM562795), Vitória Rodrigues (RM565160), Augusto Bonomo (RM565155), Thomas Fontes (RM562254), Matheus Molina (RM563399)*
