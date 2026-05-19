-- DML - CARGA DE DADOS PARA TESTES - CHALLENGE CLYVO VET

-- 1. INSERINDO TUTORES (EQUIPE)
INSERT INTO T_TUTOR (cpf, nome, telefone, email, qtd_pets) VALUES ('12345678900', 'Gabriel Maciel', '(11) 99999-0001', 'gabriel@email.com', 2);
INSERT INTO T_TUTOR (cpf, nome, telefone, email, qtd_pets) VALUES ('22345678900', 'Vitória Rodrigues', '(11) 99999-0002', 'vitoria@email.com', 1);
INSERT INTO T_TUTOR (cpf, nome, telefone, email, qtd_pets) VALUES ('32345678900', 'Augusto Bonomo', '(11) 99999-0003', 'augusto@email.com', 1);

-- 2. INSERINDO MÉDICOS E CLÍNICAS
INSERT INTO T_MEDICO_ESPECIALISTA (nome, especialidade) VALUES ('Dr. Anderson Rodrigues', 'NEURO');
INSERT INTO T_MEDICO_ESPECIALISTA (nome, especialidade) VALUES ('Dra. Juliana Mendes', 'CARDIO');
INSERT INTO T_CLINICA (nome_cnpj, telefone, latitude, longitude, bairro, cidade, estado, atendimento_24h) 
VALUES ('Hospital Vet FIAP - 99.888.777/0001-10', '(11) 4002-8922', -23.561494, -46.656461, 'Jardim Paulista', 'São Paulo', 'SP', 1);

-- 3. INSERINDO PETS
-- Usando Raca_id 1 (Golden) e 2 (Bulldog) que já estão no DDL
INSERT INTO T_PET (nome, data_nascimento, peso, raca_id, tutor_cpf, status_longevidade) 
VALUES ('Geralda', TO_DATE('2022-05-10', 'YYYY-MM-DD'), 12.5, 2, '12345678900', 'IA: Saúde estável. Atenção redobrada com a respiração.');

INSERT INTO T_PET (nome, data_nascimento, peso, raca_id, tutor_cpf, status_longevidade) 
VALUES ('Max', TO_DATE('2018-01-15', 'YYYY-MM-DD'), 30.2, 1, '22345678900', 'IA: Alerta preventivo para exames ortopédicos.');

-- 4. INSERINDO EVENTOS (Consultas)
INSERT INTO T_EVENTO (tipo, id_pet, id_tutor, id_medico_especialista, id_clinica) 
VALUES ('CONSULTA ESPECIALISTA', 1, '12345678900', 1, 1);

-- 5. INSERINDO HISTÓRICO CLÍNICO
INSERT INTO T_HISTORICO_CLINICO (id_evento, data_evento, status, observacoes_ia) 
VALUES (1, SYSDATE, 'REALIZADO', 'IA: Paciente apresenta boa evolução clínica após o início do tratamento preventivo.');

-- 6. INSERINDO TRATAMENTOS
INSERT INTO T_TRATAMENTO (id_pet, nome_medicamento, frequencia, data_inicio, data_final) 
VALUES (1, 'Limpeza Auricular', '2x por semana', SYSDATE, SYSDATE + 30);

-- 7. INSERINDO CATÁLOGO DE SERVIÇOS
INSERT INTO T_TIPO_EVENTO_CATALOGO (descricao, categoria) VALUES ('Vacina V10', 'Preventivo');
INSERT INTO T_TIPO_EVENTO_CATALOGO (descricao, categoria) VALUES ('Vermifugação', 'Preventivo');
INSERT INTO T_TIPO_EVENTO_CATALOGO (descricao, categoria) VALUES ('Consulta Cardiologia', 'Especialista');

-- 8. INSERINDO SERVIÇOS DA CLÍNICA
INSERT INTO T_SERVICO_CLINICA (id_clinica, id_tipo_catalogo, disponivel) VALUES (1, 1, 1);
INSERT INTO T_SERVICO_CLINICA (id_clinica, id_tipo_catalogo, disponivel) VALUES (1, 2, 1);

-- 9. INSERINDO CONTEXTO DE LOCALIZAÇÃO DO TUTOR
INSERT INTO T_CONTEXTO_LOCALIZACAO (cpf_tutor, latitude_atual, longitude_atual, data_hora_captura, cidade_detectada) 
VALUES ('12345678900', -23.563000, -46.654000, SYSTIMESTAMP, 'São Paulo');

COMMIT;
