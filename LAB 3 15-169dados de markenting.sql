-- Verifica os dados
SELECT * FROM cap15.dsa_campanha_marketing;
--===================================================================
																		--INDENTIFICANDO OS PROBLEMAS -- LAB 2/3
--===================================================================
-- Crie uma unica query que indentifique o total de valores ausentes em todas as colunas 
SELECT
	COUNT(*) - COUNT(id) AS id_missing,
	COUNT(*) - COUNT(nome_campanha) AS nome_campanha_missing,
	COUNT(*) - COUNT(data_inicio) AS data_inicio_missing,
	COUNT(*) - COUNT(data_fim) AS data_fim_missing,
	COUNT(*) - COUNT(orcamento) AS orcamento_missing,
	COUNT(*) - COUNT(publico_alvo) AS publico_alvo_id_missing,
	COUNT(*) - COUNT(canais_divulgacao) AS canais_divulgacao_id_missing,
	COUNT(*) - COUNT(tipo_campanha) AS tipo_campanha_id_missing,
	COUNT(*) - COUNT(taxa_conversao) AS taxa_conversao_id_missing,
	COUNT(*) - COUNT(impressoes) AS impressoes_id_missing
FROM
	cap15.dsa_campanha_marketing;

--  1 Crie uma unica query que indentifique se em qualquer coluna há o caracter "?".
SELECT *
FROM cap15.dsa_campanha_marketing
WHERE 
    nome_campanha LIKE '%?%' OR
    CAST(data_inicio AS VARCHAR) LIKE '%?%' OR
    CAST(data_fim AS VARCHAR) LIKE '%?%' OR
    CAST(orcamento AS VARCHAR) LIKE '%?%' OR
    publico_alvo LIKE '%?%' OR
    canais_divulgacao LIKE '%?%' OR
    tipo_campanha LIKE '%?%' OR
    CAST(taxa_conversao AS VARCHAR) LIKE '%?%' OR
    CAST(impressoes AS VARCHAR) LIKE '%?%';
	
-- 2 Crie uma query que indentifique duplicatas (SEM CONSIDERAR A COLUNA ID)
SELECT
	nome_campanha, data_inicio, data_fim, orcamento, publico_alvo,
	canais_divulgacao, tipo_campanha, taxa_conversao, impressoes,
	COUNT(*) AS duplicatas
FROM cap15.dsa_campanha_marketing
GROUP BY 
	nome_campanha, data_inicio, data_fim, orcamento, publico_alvo,
	canais_divulgacao, tipo_campanha, taxa_conversao, impressoes
HAVING COUNT(*) > 1;

-- 3  Crie uma query que identifique duplicatas considerando as colunas
--(nome_campanha, data_inicio, publico-alvo, canais_divulgacao)
SELECT
	nome_campanha, data_inicio, 
	publico_alvo, canais_divulgacao,
	COUNT(*) AS duplicatas
FROM cap15.dsa_campanha_marketing
GROUP BY nome_campanha, data_inicio, 
publico_alvo, canais_divulgacao
HAVING COUNT(*) >= 1;
-- 4 agora sem mudar a regra logo a cima me mostre todas as colunas
SELECT *
FROM cap15.dsa_campanha_marketing
WHERE 
    (nome_campanha, data_inicio, publico_alvo, canais_divulgacao) IN (
        SELECT 
            nome_campanha, 
            data_inicio, 
            publico_alvo, 
            canais_divulgacao
        FROM 
            cap15.dsa_campanha_marketing
        GROUP BY 
            nome_campanha, 
            data_inicio, 
            publico_alvo, 
            canais_divulgacao
        HAVING 
            COUNT(*) > 1
    );

-- 5 Crie uma query que indentifique outliers nas 3 colunas númericas.
-- Considere como outliers valores que estejam acima ou abaixo das seguintes regras:
-- media + 1.5 * desvio_padrao
-- media - 1.5 * desvio_padrao
WITH stats AS (
    SELECT
        AVG(orcamento) AS avg_orcamento,
        STDDEV(orcamento) AS stddev_orcamento,
        AVG(taxa_conversao) AS avg_taxa_conversao,
        STDDEV(taxa_conversao) AS stddev_taxa_conversao,
        AVG(impressoes) AS avg_impressoes,
        STDDEV(impressoes) AS stddev_impressoes
    FROM
        cap15.dsa_campanha_marketing-- DAQUI PRA CIMA CALCULANDO MEDIA E DESVIO PADRAO
)
SELECT
    id,
    nome_campanha,
    data_inicio,
    data_fim,
    orcamento,
    publico_alvo,
    canais_divulgacao,
    taxa_conversao,
    impressoes
FROM
    cap15.dsa_campanha_marketing,
    stats
WHERE -- INDENTIFICA SE TEM OUTLIERS E UMA DAS 3 COLUNAS FOCU
    orcamento < (avg_orcamento - 1.5 * stddev_orcamento) OR 
    orcamento > (avg_orcamento + 1.5 * stddev_orcamento) OR
    taxa_conversao < (avg_taxa_conversao - 1.5 * stddev_taxa_conversao) OR 
    taxa_conversao > (avg_taxa_conversao + 1.5 * stddev_taxa_conversao) OR
    impressoes < (avg_impressoes - 1.5 * stddev_impressoes) OR 
    impressoes > (avg_impressoes + 1.5 * stddev_impressoes);
--===================================================================--===================================================================--=================================================
																		--RESOLVENDO -- LAB 2/3
--===================================================================--===================================================================--==================================================
-- Verifica os dados
SELECT * FROM cap15.dsa_campanha_marketing;

-- 1 Crie uma query que identifique os valores unicos da coluna publico_alvo em seguida atualize a tabela no lugar de '?'colocar outros
SELECT --1
	publico_alvo,
	COUNT (*) DISTINCT
FROM cap15.dsa_campanha_marketing
GROUP BY publico_alvo;

UPDATE cap15.dsa_campanha_marketing --2
SET publico_alvo = 'Outros'
WHERE publico_alvo = '?';-- aqui resolvemos o problema de caracter especial

-- 2 Crie uma query que identifique o total de registros de cada valor da coluna canais_divulgacao.
-- Crie uma query que substitua os valores ausentes pela moda da coluna canais_divulgacao
-- em seguida encontre a moda  da coluna canais_divulgacao e atualize os dados NULLL com o a moda atravez do UPDATE
SELECT COUNT (*), --1
	canais_divulgacao
FROM cap15.dsa_campanha_marketing
GROUP BY canais_divulgacao;

SELECT canais_divulgacao-- 1
FROM cap15.dsa_campanha_marketing
WHERE canais_divulgacao IS NOT NULL
GROUP BY canais_divulgacao
ORDER BY count(*) DESC -- A MODA E A  VARIAVEL QUE APARECE COM MAIS FREQUENCIA NOS DADOS ASSIM PEGAMOS A MAIOR
LIMIT 1;

UPDATE cap15.dsa_campanha_marketing --3
SET canais_divulgacao = 'Redes Sociais'
WHERE canais_divulgacao IS NULL; -- nao esquecer do where se nao vai atualizar todos os registro.

-- 3 Crie uma query que identifica o total de registros de cada valor da coluna tipo_campanha
--Considere que os valores ausente na coluna tipo_campanha sejam erros de coleta de dados
--Crie uma querry com delete que remova os registros onde tipo_campanha tiver valor nulo.
SELECT -- 1
	tipo_campanha,
	COUNT(*)
FROM cap15.dsa_campanha_marketing
GROUP BY tipo_campanha;

DELETE FROM cap15.dsa_campanha_marketing -- 2
WHERE tipo_campanha IS NULL; -- DELETANDO OS DADOS NULOS
--===================================================================--===================================================================--=================================================
																		--RESOLVENDO -- LAB 3/2
--===================================================================--===================================================================--==================================================
-- 4 Crie uma query que identifique valores ausente na coluna orçamento
-- Considere que orçamento nulo para público alvo igual "Outros" nào seja uma informação relevante.
-- Crie um query com delete que remova registros se a coluna orcamento tiver valor ausente e a coluna publico_alvo tiver o valor 'Outros'
SELECT *
FROM cap15.dsa_campanha_marketing
WHERE orcamento IS NULL;

DELETE FROM cap15.dsa_campanha_marketing
WHERE orcamento IS NULL AND publico_alvo = 'Outros'

-- 5 Crie uma query que preencha os valores ausentes da coluna orcamento com a média da coluna (INTERPOLACAO)
-- mas segmentado pela coluna canais_divulgacao.
--(chegar na media mais proxima do que seria por grupo na ausencia de valor ou calcular media total da coluna)
-- e faça o UPDATE

SELECT canais_divulgacao, AVG(orcamento) AS media_orcamento -- PRIMEIRO , VAMOS CALCULAR A MEDIA
FROM cap15.dsa_campanha_marketing
WHERE orcamento IS NOT NULL
GROUP BY canais_divulgacao;

UPDATE cap15.dsa_campanha_marketing AS c
SET orcamento = d.media_orcamento
FROM ( -- COLOCANDO A MEDIA DENTRO DO UPDATE
	SELECT canais_divulgacao, AVG(orcamento) AS media_orcamento
	FROM cap15.dsa_campanha_marketing
	WHERE orcamento IS NOT NULL
	GROUP BY canais_divulgacao
) AS d
WHERE c.canais_divulgacao = d.canais_divulgacao AND c.orcamento IS NULL;

SELECT * FROM cap15.dsa_campanha_marketing
------------ aqui zeramos todos os valores nulos da nossa tabela

------- agora iniciara a identificasao de OUTLIERS (e um problema ? depende)

-- 6 Use como estratégia de tratamento de outliers criar uma nova coluna e preenchê-la com True
-- Se houver outlier no registro e False caso contrario

ALTER TABLE cap15.dsa_campanha_marketing -- alterando a tabela e criando uma nova coluna
ADD COLUMN tem_outlier BOOLEAN DEFAULT FALSE;

-- inserindo os dados na nova coluna
WITH stats AS (
    SELECT
        AVG(orcamento) AS avg_orcamento,
        STDDEV(orcamento) AS stddev_orcamento,
        AVG(taxa_conversao) AS avg_taxa_conversao,
        STDDEV(taxa_conversao) AS stddev_taxa_conversao,
        AVG(impressoes) AS avg_impressoes,
        STDDEV(impressoes) AS stddev_impressoes
    FROM
        cap15.dsa_campanha_marketing
)
UPDATE cap15.dsa_campanha_marketing
SET tem_outlier = TRUE
FROM stats
WHERE
    orcamento < (avg_orcamento - 1.5 * stddev_orcamento) OR 
    orcamento > (avg_orcamento + 1.5 * stddev_orcamento) OR
    taxa_conversao < (avg_taxa_conversao - 1.5 * stddev_taxa_conversao) OR 
    taxa_conversao > (avg_taxa_conversao + 1.5 * stddev_taxa_conversao) OR
    impressoes < (avg_impressoes - 1.5 * stddev_impressoes) OR 
    impressoes > (avg_impressoes + 1.5 * stddev_impressoes);
	
SELECT * FROM cap15.dsa_campanha_marketing -- conferindo as atualizaçoes

SELECT tem_outlier, COUNT(*) AS contagem -- vendo quantos outliers estao na massa de dados
FROM cap15.dsa_campanha_marketing
GROUP BY tem_outlier;
--===================================================================--===================================================================--=================================================
															--AGORA VAMOS PRERARAR OS DADOS PARA UM MODELO DE ML  -- LAB 3/2
--===================================================================--===================================================================--==================================================
-- 7 Aplique Label Encoding na coluna publico_alvo e salve o resultado em uma nova coluna
-- chamada publico_alvo_encoded
SELECT * FROM cap15.dsa_campanha_marketing

ALTER TABLE cap15.dsa_campanha_marketing -- Criando a nova coluna
ADD COLUMN publico_alvo_encoded INT;

SELECT DISTINCT publico_alvo -- Verificando os valores unicos
FROM cap15.dsa_campanha_marketing;

UPDATE cap15.dsa_campanha_marketing -- MODIFICAMOS O DADO SEM MODIFICAR A INFORMACAO
SET publico_alvo_encoded =
	CASE publico_alvo
		WHEN 'Publico Alvo 1' THEN 1
		WHEN 'Publico Alvo 2' THEN 2
		WHEN 'Publico Alvo 3' THEN 3
		WHEN 'Publico Alvo 4' THEN 4
		WHEN 'Publico Alvo 5' THEN 5
		WHEN 'Outros' THEN 0
		ELSE NULL -- SE ACHAR ALGUMA OUTRA OBERVACAO SERA NULA
	END;
SELECT * FROM cap15.dsa_campanha_marketing -- VERIFICANDO

---- 8 Aplique Label Encoding na coluna canais_divulgacao e salve o resultado em uma nova coluna
-- chamada canais_divulgacao_encoded
ALTER TABLE cap15.dsa_campanha_marketing -- Criando a nova coluna
ADD COLUMN canais_divulgacao_encoded INT;

SELECT DISTINCT canais_divulgacao, COUNT(*) AS total_registros -- Verificando os valores unicos
FROM cap15.dsa_campanha_marketing
GROUP BY canais_divulgacao;

UPDATE cap15.dsa_campanha_marketing -- MODIFICAMOS O DADO SEM MODIFICAR A INFORMACAO
SET canais_divulgacao_encoded =
	CASE canais_divulgacao
		WHEN 'Google' THEN 1
		WHEN 'Redes Sociais' THEN 2
		WHEN 'Sites de Notícias' THEN 3
		ELSE NULL -- SE ACHAR ALGUMA OUTRA OBERVACAO SERA NULA
	END;
SELECT * FROM cap15.dsa_campanha_marketing -- VERIFICANDO

-- 9 Aplique Label Encoding na coluna tipo_campanha e salve o resultado em uma nova coluna
-- chamada tipo_campanha_encoded
ALTER TABLE cap15.dsa_campanha_marketing -- Criando a nova coluna
ADD COLUMN tipo_campanha_encoded INT;

SELECT DISTINCT tipo_campanha, COUNT(*) AS total_registros -- Verificando os valores unicos
FROM cap15.dsa_campanha_marketing
GROUP BY tipo_campanha;

UPDATE cap15.dsa_campanha_marketing -- MODIFICAMOS O DADO SEM MODIFICAR A INFORMACAO
SET tipo_campanha_encoded =
	CASE tipo_campanha
		WHEN 'Promocional' THEN 1
		WHEN 'Mais Seguidores' THEN 2
		WHEN 'Divulgação' THEN 3
		ELSE NULL -- SE ACHAR ALGUMA OUTRA OBERVACAO SERA NULA
	END;
SELECT * FROM cap15.dsa_campanha_marketing -- VERIFICANDO
--===================================================================--===================================================================--=================================================
															--EXCLUINDO AS TABELAS CATEGORICAS  -- LAB 3/2
--===================================================================--===================================================================--==================================================

-- PODERIAMOS TER CRIADO OS DADOS NUMERICOS NA PROPIA COLUNA POREM ASSIM NAO TERIAMOS COMO COMPRAR SE ESTAVA CERTO OU NAO
-- TEMOS QUE DELETAR AS COLUNAS CATEGORICAS POSI AGORA SAO INFOMAÇOES DUPLICADAS
-- E COMO O FOCO E UM  MODELO DE ML E NAO UMA DASH VAMOS EXCLUILAS
ALTER TABLE cap15.dsa_campanha_marketing
DROP COLUMN publico_alvo,
DROP COLUMN canais_divulgacao,
DROP COLUMN tipo_campanha;

SELECT * FROM cap15.dsa_campanha_marketing -- VERIFICANDO

-- verificando se ficou algum valor nulo -- nao esquecer de modificar a query para as novas colunas
SELECT
	COUNT(*) - COUNT(id) AS id_missing,
	COUNT(*) - COUNT(nome_campanha) AS nome_campanha_missing,
	COUNT(*) - COUNT(data_inicio) AS data_inicio_missing,
	COUNT(*) - COUNT(data_fim) AS data_fim_missing,
	COUNT(*) - COUNT(orcamento) AS orcamento_missing,
	COUNT(*) - COUNT(publico_alvo_encoded) AS publico_alvo_id_missing,
	COUNT(*) - COUNT(canais_divulgacao_encoded) AS canais_divulgacao_id_missing,
	COUNT(*) - COUNT(tipo_campanha_encoded) AS tipo_campanha_id_missing,
	COUNT(*) - COUNT(taxa_conversao) AS taxa_conversao_id_missing,
	COUNT(*) - COUNT(impressoes) AS impressoes_id_missing
FROM
	cap15.dsa_campanha_marketing;
-- finalizado todos os tratamentos
--===================================================================--===================================================================--=================================================
															--CRIAÇAO DE RELATORIOS  -- LAB 3/2
--===================================================================--===================================================================--==================================================
-- Relatorio de resumo com variaveis Quantitativas
-- Totais dos anos 2022, 2023 e 2024 para as colunas orcamento,taxa_conversao e impressoes
SELECT * FROM cap15.dsa_campanha_marketing

SELECT 
	TO_CHAR(data_inicio, 'YYYY') AS ano,
	SUM(orcamento) AS total_orcamento,
	SUM(taxa_conversao) AS total_taxa_conversao,
	SUM(impressoes) AS total_impressoes
FROM cap15.dsa_campanha_marketing
WHERE EXTRACT(YEAR FROM data_inicio) IN(2022,2023,2024)
GROUP BY TO_CHAR(data_inicio, 'YYYY')
ORDER BY TO_CHAR(data_inicio, 'YYYY') DESC;

-- FAZENDO UM PIVOT COM DADOS - AJUDA A CRIAR GRAFICOS
-- Relatório de Resumo Com Variáveis Quantitativas e Pivot da Tabela APENAS UMA LINHA
SELECT
    'Total' as Total,
    SUM(CASE WHEN EXTRACT(YEAR FROM data_inicio) = 2022 THEN orcamento ELSE 0 END) AS "Orcamento_2022",
    SUM(CASE WHEN EXTRACT(YEAR FROM data_inicio) = 2022 THEN taxa_conversao ELSE 0 END) AS "Taxa_Conversao_2022",
    SUM(CASE WHEN EXTRACT(YEAR FROM data_inicio) = 2022 THEN impressoes ELSE 0 END) AS "Impressoes_2022",
    SUM(CASE WHEN EXTRACT(YEAR FROM data_inicio) = 2023 THEN orcamento ELSE 0 END) AS "Orcamento_2023",
    SUM(CASE WHEN EXTRACT(YEAR FROM data_inicio) = 2023 THEN taxa_conversao ELSE 0 END) AS "Taxa_Conversao_2023",
    SUM(CASE WHEN EXTRACT(YEAR FROM data_inicio) = 2023 THEN impressoes ELSE 0 END) AS "Impressoes_2023",
    SUM(CASE WHEN EXTRACT(YEAR FROM data_inicio) = 2024 THEN orcamento ELSE 0 END) AS "Orcamento_2024",
    SUM(CASE WHEN EXTRACT(YEAR FROM data_inicio) = 2024 THEN taxa_conversao ELSE 0 END) AS "Taxa_Conversao_2024",
    SUM(CASE WHEN EXTRACT(YEAR FROM data_inicio) = 2024 THEN impressoes ELSE 0 END) AS "Impressoes_2024"
FROM
    cap15.dsa_campanha_marketing;
--===================================================================--===================================================================--=================================================
															--PADRONIZAÇAO/NORMALIZACAO DOS DADOS  -- LAB 3/2
--===================================================================--===================================================================--==================================================
-- Normalização de Dados com SQL
-- A normalização Min-Max é um método utilizado em estatística e aprendizado de máquina 
-- para transformar características (features) de dados para uma escala comum, sem distorcer 
-- as diferenças nos intervalos de valores. Este método é útil para algoritmos de aprendizado 
-- que são sensíveis a variações nas escalas dos dados, como redes neurais e algoritmos 
-- baseados em distância (por exemplo, K-NN).

-- Selecione id, nome_campanha, data_inicio e data_fim, junto com orcamento e taxa_conversao normalizados

-- Sem normalização

SELECT
    id,
    nome_campanha,
    data_inicio,
    data_fim,
    orcamento,
    taxa_conversao
FROM
    cap15.dsa_campanha_marketing;

-- Com normalização

WITH min_max AS (
    SELECT
        MIN(orcamento) as min_orcamento,
        MAX(orcamento) as max_orcamento,
        MIN(taxa_conversao) as min_taxa_conversao,
        MAX(taxa_conversao) as max_taxa_conversao
    FROM
        cap15.dsa_campanha_marketing
)
SELECT
    id,
    nome_campanha,
    data_inicio,
    data_fim,
    ROUND((orcamento - min_orcamento) / (max_orcamento - min_orcamento),5) as orcamento_normalizado,
    ROUND((taxa_conversao - min_taxa_conversao) / (max_taxa_conversao - min_taxa_conversao),5) as taxa_conversao_normalizada
FROM
    cap15.dsa_campanha_marketing, min_max;