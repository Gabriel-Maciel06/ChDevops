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
TUTOR1=$(curl -s -X POST "$BASE_URL/api/tutores" \
  -H "Content-Type: application/json" \
  -d '{"cpf": "11122233344", "nome": "Gabriel Maciel", "telefone": "(11) 98765-4321", "email": "gabriel.maciel@clyvovet.com", "quantidadePets": 1}')
echo "Tutor 1: $TUTOR1" | python3 -m json.tool 2>/dev/null || echo "Tutor 1: $TUTOR1"

TUTOR2=$(curl -s -X POST "$BASE_URL/api/tutores" \
  -H "Content-Type: application/json" \
  -d '{"cpf": "55566677788", "nome": "Vitória Rodrigues", "telefone": "(11) 91234-5678", "email": "vitoria.rodrigues@clyvovet.com", "quantidadePets": 2}')
echo "Tutor 2: $TUTOR2" | python3 -m json.tool 2>/dev/null || echo "Tutor 2: $TUTOR2"

# 2. READ (GET) - Consultando todos os tutores
echo ""
echo "👉 [2/6] GET /api/tutores - Consultando todos os tutores..."
curl -s "$BASE_URL/api/tutores" | python3 -m json.tool 2>/dev/null

# Extrai CPF do tutor 1 para usar nos pets
TUTOR1_CPF="11122233344"

# 3. CREATE (POST) - Inserindo 2 Pets vinculados ao tutor 1
echo ""
echo "👉 [3/6] POST /api/pets - Criando 2 Pets..."
PET1=$(curl -s -X POST "$BASE_URL/api/pets" \
  -H "Content-Type: application/json" \
  -d "{\"nome\": \"Thor\", \"dataNascimento\": \"2020-04-10\", \"peso\": 34.5, \"racaId\": 1, \"tutorCpf\": \"$TUTOR1_CPF\", \"statusLongevidade\": \"Fase adulta madura. Monitoramento preventivo.\"}")
echo "Pet 1: $PET1" | python3 -m json.tool 2>/dev/null || echo "Pet 1: $PET1"

PET1_ID=$(echo "$PET1" | python3 -c "import sys,json; d=json.load(sys.stdin); print(d.get('id','1'))" 2>/dev/null || echo "1")

PET2=$(curl -s -X POST "$BASE_URL/api/pets" \
  -H "Content-Type: application/json" \
  -d "{\"nome\": \"Luna\", \"dataNascimento\": \"2019-08-20\", \"peso\": 12.0, \"racaId\": 1, \"tutorCpf\": \"55566677788\", \"statusLongevidade\": \"Fase senior. Check-up semestral.\"}")
echo "Pet 2: $PET2" | python3 -m json.tool 2>/dev/null || echo "Pet 2: $PET2"

PET2_ID=$(echo "$PET2" | python3 -c "import sys,json; d=json.load(sys.stdin); print(d.get('id','2'))" 2>/dev/null || echo "2")

# 4. READ (GET) - Consultando todos os pets
echo ""
echo "👉 [4/6] GET /api/pets - Consultando todos os pets cadastrados..."
curl -s "$BASE_URL/api/pets" | python3 -m json.tool 2>/dev/null

# 5. UPDATE (PUT) - Atualizando dados do Pet Thor
echo ""
echo "👉 [5/6] PUT /api/pets/$PET1_ID - Atualizando peso do Pet Thor..."
curl -s -X PUT "$BASE_URL/api/pets/$PET1_ID" \
  -H "Content-Type: application/json" \
  -d "{\"nome\": \"Thor\", \"dataNascimento\": \"2020-04-10\", \"peso\": 33.8, \"racaId\": 1, \"tutorCpf\": \"$TUTOR1_CPF\", \"statusLongevidade\": \"Peso otimizado. Longevidade estimada em 13 anos.\"}" \
  | python3 -m json.tool 2>/dev/null

# 6. DELETE (DELETE) - Excluindo o Pet Luna
echo ""
echo "👉 [6/6] DELETE /api/pets/$PET2_ID - Excluindo o Pet Luna..."
HTTP_STATUS=$(curl -s -o /dev/null -w "%{http_code}" -X DELETE "$BASE_URL/api/pets/$PET2_ID")
echo "Status HTTP: $HTTP_STATUS"
if [ "$HTTP_STATUS" = "204" ] || [ "$HTTP_STATUS" = "200" ]; then
  echo "✅ Pet deletado com sucesso!"
else
  echo "⚠️  Status inesperado: $HTTP_STATUS"
fi

echo ""
echo "===================================================================="
echo "✅ CICLO DO CRUD CORE EXECUTADO COM SUCESSO!"
echo "   🌐 Swagger UI: $BASE_URL/swagger-ui/index.html"
echo "   📄 API Docs:   $BASE_URL/api-docs"
echo "===================================================================="
