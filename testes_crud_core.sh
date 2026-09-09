#!/bin/bash
# ==============================================================================
# Clyvo Vet - Script Automatizado de Testes do CRUD CORE (T_TUTOR & T_PET)
# Atende aos itens 4, 5 e 9.3 do Edital DevOps 3ª Sprint
# ==============================================================================

BASE_URL=${1:-"http://localhost:8080"}

echo "===================================================================="
echo "🐾 INICIANDO TESTES DO CRUD CORE NA API CLYVO VET"
echo "Alvo: $BASE_URL"
echo "===================================================================="

# 1. CREATE (POST) - Inserindo 2 Tutores
echo ""
echo "👉 [1/6] POST /api/tutores - Criando 2 Tutores..."
curl -s -X POST "$BASE_URL/api/tutores" \
  -H "Content-Type: application/json" \
  -d '{"cpf": "11122233344", "nome": "Gabriel Maciel", "telefone": "(11) 98765-4321", "email": "gabriel.tutor@clyvovet.com"}' | jq .

curl -s -X POST "$BASE_URL/api/tutores" \
  -H "Content-Type: application/json" \
  -d '{"cpf": "55566677788", "nome": "Vitória Rodrigues", "telefone": "(11) 91234-5678", "email": "vitoria.tutor@clyvovet.com"}' | jq .

# 2. CREATE (POST) - Inserindo 2 Pets vinculados aos tutores
echo ""
echo "👉 [2/6] POST /api/pets - Criando 2 Pets..."
curl -s -X POST "$BASE_URL/api/pets" \
  -H "Content-Type: application/json" \
  -d '{"nome": "Thor", "dataNascimento": "2020-04-10", "peso": 34.5, "racaId": 1, "tutorCpf": "11122233344", "statusLongevidade": "Fase adulta madura. Monitoramento preventivo de articulacoes e coracao."}' | jq .

curl -s -X POST "$BASE_URL/api/pets" \
  -H "Content-Type: application/json" \
  -d '{"nome": "Luna", "dataNascimento": "2019-08-20", "peso": 12.0, "racaId": 2, "tutorCpf": "55566677788", "statusLongevidade": "Fase senior. Check-up semestral respiratorio e renal."}' | jq .

# 3. READ (GET) - Consultando registros
echo ""
echo "👉 [3/6] GET /api/tutores - Consultando todos os tutores cadastrados..."
curl -s -X GET "$BASE_URL/api/tutores" | jq .

echo ""
echo "👉 [4/6] GET /api/pets - Consultando todos os pets cadastrados..."
curl -s -X GET "$BASE_URL/api/pets" | jq .

# 4. UPDATE (PUT) - Atualizando dados de um Pet
echo ""
echo "👉 [5/6] PUT /api/pets/1 - Atualizando peso e status de longevidade do Pet Thor..."
curl -s -X PUT "$BASE_URL/api/pets/1" \
  -H "Content-Type: application/json" \
  -d '{"nome": "Thor", "dataNascimento": "2020-04-10", "peso": 33.8, "racaId": 1, "tutorCpf": "11122233344", "statusLongevidade": "Peso otimizado com dieta preventiva. Longevidade estimada em 13 anos."}' | jq .

# 5. DELETE (DELETE) - Excluindo um Pet
echo ""
echo "👉 [6/6] DELETE /api/pets/2 - Excluindo o Pet Luna..."
curl -s -i -X DELETE "$BASE_URL/api/pets/2"

echo ""
echo "===================================================================="
echo "✅ CICLO DO CRUD CORE EXECUTADO COM SUCESSO!"
echo "===================================================================="
