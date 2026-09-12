#!/bin/bash
# ==============================================================================
# Clyvo Vet - Testes Automatizados do CRUD CORE (T_TUTOR & T_PET) na nuvem
# Atende aos itens 4, 5 e 9.3 do edital: CRUD completo nas DUAS tabelas
# relacionadas (1:N), com pelo menos 2 linhas significativas em cada uma.
#
# Uso: ./testes_crud_core.sh http://<FQDN_OU_IP_DO_ACI>:8080
# Entre cada etapa, evidencie no banco com:
#   ./consultar_banco_nuvem.sh "SELECT * FROM T_TUTOR"
#   ./consultar_banco_nuvem.sh "SELECT id, nome, peso, raca_id, tutor_cpf, status_longevidade FROM T_PET"
# ==============================================================================
BASE_URL=${1:-"http://localhost:8080"}
PAUSA=${PAUSA:-0}   # ex.: PAUSA=1 ./testes_crud_core.sh URL  -> pausa entre etapas (para o vídeo)

json() { python3 -m json.tool 2>/dev/null || cat; }
pausa() { if [ "$PAUSA" = "1" ]; then read -r -p "   ⏸  Evidencie no banco e pressione ENTER para continuar..."; fi; }
titulo() { echo; echo "👉 $1"; }

echo "===================================================================="
echo "🐾 TESTES DO CRUD CORE - CLYVO VET (T_TUTOR 1:N T_PET)"
echo "Alvo: $BASE_URL"
echo "===================================================================="

# ---------------------------------------------------------------- CREATE
titulo "[1/9] CREATE - POST /api/tutores (2 tutores)"
curl -s -X POST "$BASE_URL/api/tutores" -H "Content-Type: application/json" \
  -d '{"cpf":"11122233344","nome":"Gabriel Maciel","telefone":"(11) 98765-4321","email":"gabriel.maciel@clyvovet.com","quantidadePets":1}' | json
curl -s -X POST "$BASE_URL/api/tutores" -H "Content-Type: application/json" \
  -d '{"cpf":"55566677788","nome":"Vitória Rodrigues","telefone":"(11) 91234-5678","email":"vitoria.rodrigues@clyvovet.com","quantidadePets":1}' | json
pausa

titulo "[2/9] CREATE - POST /api/pets (2 pets, um para cada tutor)"
PET1=$(curl -s -X POST "$BASE_URL/api/pets" -H "Content-Type: application/json" \
  -d '{"nome":"Thor","dataNascimento":"2020-04-10","peso":34.5,"racaId":1,"tutorCpf":"11122233344","statusLongevidade":"Fase adulta madura. Monitoramento preventivo semestral."}')
echo "$PET1" | json
PET2=$(curl -s -X POST "$BASE_URL/api/pets" -H "Content-Type: application/json" \
  -d '{"nome":"Luna","dataNascimento":"2017-08-20","peso":12.0,"racaId":2,"tutorCpf":"55566677788","statusLongevidade":"Fase sênior. Check-up cardiorrespiratório trimestral."}')
echo "$PET2" | json
PET1_ID=$(echo "$PET1" | python3 -c "import sys,json; print(json.load(sys.stdin)['id'])" 2>/dev/null || echo "1")
PET2_ID=$(echo "$PET2" | python3 -c "import sys,json; print(json.load(sys.stdin)['id'])" 2>/dev/null || echo "2")
pausa

# ---------------------------------------------------------------- READ
titulo "[3/9] READ - GET /api/tutores e GET /api/pets"
curl -s "$BASE_URL/api/tutores" | json
curl -s "$BASE_URL/api/pets" | json

titulo "[4/9] READ - GET /api/pets/$PET2_ID (HATEOAS + insight preditivo) e GET /api/tutores/11122233344/pets"
curl -s "$BASE_URL/api/pets/$PET2_ID" | json
curl -s "$BASE_URL/api/tutores/11122233344/pets" | json
pausa

# ---------------------------------------------------------------- UPDATE
titulo "[5/9] UPDATE - PUT /api/pets/$PET1_ID (peso 34.5 -> 33.8 e novo parecer)"
curl -s -X PUT "$BASE_URL/api/pets/$PET1_ID" -H "Content-Type: application/json" \
  -d '{"nome":"Thor","dataNascimento":"2020-04-10","peso":33.8,"racaId":1,"tutorCpf":"11122233344","statusLongevidade":"Peso otimizado. Longevidade estimada em 13 anos."}' | json

titulo "[6/9] UPDATE - PUT /api/tutores/55566677788 (novo telefone e quantidadePets)"
curl -s -X PUT "$BASE_URL/api/tutores/55566677788" -H "Content-Type: application/json" \
  -d '{"cpf":"55566677788","nome":"Vitória Rodrigues Martins","telefone":"(11) 99999-0002","email":"vitoria.rodrigues@clyvovet.com","quantidadePets":2}' | json
pausa

# ---------------------------------------------------------------- DELETE
titulo "[7/9] DELETE - DELETE /api/pets/$PET2_ID (Luna)"
echo "Status HTTP: $(curl -s -o /dev/null -w '%{http_code}' -X DELETE "$BASE_URL/api/pets/$PET2_ID")  (esperado 204)"

titulo "[8/9] DELETE - DELETE /api/tutores/55566677788 (Vitória)"
echo "Status HTTP: $(curl -s -o /dev/null -w '%{http_code}' -X DELETE "$BASE_URL/api/tutores/55566677788")  (esperado 204)"
pausa

# ---------------------------------------------------------------- CONFIRMAÇÃO
titulo "[9/9] CONFIRMAÇÃO - registros excluídos retornam 404"
echo "GET /api/pets/$PET2_ID           -> HTTP $(curl -s -o /dev/null -w '%{http_code}' "$BASE_URL/api/pets/$PET2_ID")  (esperado 404)"
echo "GET /api/tutores/55566677788   -> HTTP $(curl -s -o /dev/null -w '%{http_code}' "$BASE_URL/api/tutores/55566677788")  (esperado 404)"
echo "Estado final:"
curl -s "$BASE_URL/api/tutores" | json
curl -s "$BASE_URL/api/pets" | json

echo
echo "===================================================================="
echo "✅ CICLO COMPLETO DO CRUD (CREATE, READ, UPDATE, DELETE) NAS 2 TABELAS"
echo "   🌐 Swagger UI: $BASE_URL/swagger-ui/index.html"
echo "===================================================================="
