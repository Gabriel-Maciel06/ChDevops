# 🎬 Roteiro de Gravação do Vídeo - DevOps Tools & Cloud Computing
**Disciplina:** DevOps Tools & Cloud Computing — 3ª Sprint (FIAP)  
**Projeto:** Clyvo Vet — Solução 100% Containerizada em Nuvem com Microsoft Azure  
**Opção Escolhida:** **Opção 1: ACR + ACI**  
**Critérios Atendidos:** 100 pontos da rubrica (sem cortes nos testes e persistência de dados).

---

## ⏱️ Cronograma Minuto a Minuto da Apresentação

### 1. 🎬 Bloco 1: Abertura & Clone do Repositório (0:00 - 1:00)
- **Ação em Tela:** Comece com o terminal aberto e mostre o repositório público no GitHub.
- **Fala:** 
  > *"Olá professor e avaliadores! Apresentamos a entrega da 3ª Sprint de DevOps Tools & Cloud Computing para a plataforma Clyvo Vet, desenvolvida pelo nosso grupo. Como exigido no edital, começamos o teste pelo clone limpo do nosso repositório no GitHub."*
- **Comando em Tela:**
  ```bash
  git clone https://github.com/Gabriel-Maciel06/ChDevops.git
  cd ChDevops
  ls -la
  ```
- **Destaque:** Mostre rapidamente os arquivos principais: `script_bd.sql`, `Dockerfile`, `deploy_azure_acr_aci.sh` e o `README.md`.

---

### 2. 🗺️ Bloco 2: Desenho da Arquitetura & Explicação da Opção 1 (1:00 - 2:00)
- **Ação em Tela:** Abra a imagem de arquitetura ou o `README.md`.
- **Fala:**
  > *"Nossa equipe selecionou a **Opção 1: ACR + ACI**, implementando uma solução corporativa 100% conteinerizada, tanto para a aplicação Java Spring Boot quanto para a persistência de banco de dados. Utilizamos o Azure Container Registry (ACR) como repositório privado das imagens e o Azure Container Instance (ACI) para executar a aplicação e o banco em nuvem de forma leve, elástica e serverless. Nosso Dockerfile segue as boas práticas de segurança, executando sob o usuário não-root `appuser`."*

---

### 3. 🚀 Bloco 3: Provisionamento 100% via Azure CLI (2:00 - 4:00)
- **Ação em Tela:** Mostre a execução do script de automação no terminal.
- **Comando:**
  ```bash
  ./deploy_azure_acr_aci.sh
  ```
- **Fala:**
  > *"Conforme a regra 8.1, todos os recursos na Azure são criados estritamente via Azure CLI. O script cria o Resource Group na região East US, provisiona o Azure Container Registry com autenticação administrativa, compila a imagem da aplicação via ACR Tasks e inicializa o Azure Container Instance com as portas 8080 e 1521 abertas e as variáveis de conexão com o banco de dados."*
- **Ação em Tela:** Abra o Portal da Azure no navegador e mostre os recursos criados: o **Resource Group**, o **Container Registry** e o **Container Group no ACI** com status `Running`.

---

### 4. 🧪 Bloco 4: Demonstração Sem Cortes do CRUD CORE & SELECT no Banco (4:00 - 8:00)
- **ATENÇÃO:** O edital exige **gravação SEM CORTES** nesta etapa e **demonstração direta no banco via SELECT** para cada operação.
- **Fala:**
  > *"Agora vamos demonstrar o ciclo completo do CRUD nas duas tabelas CORE da solução: `T_TUTOR` e `T_PET`, que possuem relacionamento 1 para N, evidenciando a persistência no banco na nuvem."*

#### Etapa 4.1: Inserção de Registros (CREATE)
- Execute o POST para inserir o Tutor Gabriel Maciel e a Tutora Vitória Rodrigues:
  ```bash
  curl -X POST "http://<IP_OU_DNS>:8080/api/tutores" -H "Content-Type: application/json" -d '{"cpf": "11122233344", "nome": "Gabriel Maciel", "telefone": "(11) 98765-4321", "email": "gabriel@clyvovet.com"}'
  ```
- Em seguida, insira os pets vinculados (Thor e Luna):
  ```bash
  curl -X POST "http://<IP_OU_DNS>:8080/api/pets" -H "Content-Type: application/json" -d '{"nome": "Thor", "dataNascimento": "2020-04-10", "peso": 34.5, "racaId": 1, "tutorCpf": "11122233344", "statusLongevidade": "Fase adulta madura."}'
  ```
- **Mostre no Banco de Dados (SELECT imediato):**
  ```sql
  SELECT * FROM T_TUTOR;
  SELECT * FROM T_PET;
  ```
  *(Aponte o cursor para os 2 registros exibidos no terminal/DBeaver)*

#### Etapa 4.2: Consulta de Registros (READ)
- Execute a consulta via cURL ou no navegador/Swagger:
  ```bash
  curl -X GET "http://<IP_OU_DNS>:8080/api/tutores"
  curl -X GET "http://<IP_OU_DNS>:8080/api/pets"
  ```
- Mostre a resposta JSON formatada com suporte HATEOAS.

#### Etapa 4.3: Atualização de Registro (UPDATE)
- Execute o PUT alterando o peso e o parecer preditivo do Pet:
  ```bash
  curl -X PUT "http://<IP_OU_DNS>:8080/api/pets/1" -H "Content-Type: application/json" -d '{"nome": "Thor", "dataNascimento": "2020-04-10", "peso": 33.8, "racaId": 1, "tutorCpf": "11122233344", "statusLongevidade": "Peso otimizado. Escore de longevidade excelente."}'
  ```
- **Mostre no Banco de Dados (SELECT imediato):**
  ```sql
  SELECT id, nome, peso, status_longevidade FROM T_PET WHERE id = 1;
  ```
  *(Evidencie a alteração do peso de 34.5 para 33.8 no banco de dados)*

#### Etapa 4.4: Exclusão de Registro (DELETE)
- Exclua um dos pets cadastrados:
  ```bash
  curl -X DELETE "http://<IP_OU_DNS>:8080/api/pets/2"
  ```
- **Mostre no Banco de Dados (SELECT imediato):**
  ```sql
  SELECT * FROM T_PET;
  ```
  *(Mostre que o registro com id 2 foi removido com sucesso)*

---

### 5. 🧹 Bloco 5: Destruição dos Recursos & Conclusão (8:00 - 9:00)
- **Ação em Tela:** Execute o script de limpeza para não gastar créditos da conta:
  ```bash
  ./destroy_azure.sh
  ```
- **Fala:**
  > *"Para encerrar, executamos a exclusão automatizada do Resource Group no Azure via CLI, garantindo governança e controle de custos de nuvem. Atendemos todos os requisitos da Sprint 3: provisionamento 100% via CLI no Azure ACR + ACI, banco de dados em nuvem, Dockerfile seguro sem root, DDL comentado e evidências completas de integração entre aplicação e banco de dados. Muito obrigado!"*
