-- ===================================================================
-- CARGA INICIAL (SEED) - Clyvo Vet
-- Executada uma única vez na criação do banco (via db/init_schema.sh).
-- Popula apenas a tabela de apoio T_RACA. As tabelas CORE (T_TUTOR e
-- T_PET) são alimentadas pela API durante a demonstração do CRUD.
-- ===================================================================
INSERT INTO T_RACA (nome, propensao_doenca, expectativa_vida, cuidados_especiais)
VALUES ('Golden Retriever', 'Displasia coxofemoral e cardiomiopatia', 12, 'Controle de peso e exames ortopédicos anuais');

INSERT INTO T_RACA (nome, propensao_doenca, expectativa_vida, cuidados_especiais)
VALUES ('Bulldog Francês', 'Síndrome braquicefálica (respiratório)', 10, 'Evitar calor excessivo e exercícios intensos');

INSERT INTO T_RACA (nome, propensao_doenca, expectativa_vida, cuidados_especiais)
VALUES ('Gato Persa', 'Doença renal policística', 14, 'Monitorar função renal semestralmente e hidratação');

COMMIT;
