
/*
===============================================================================
    0. Base de dados
===============================================================================
*/

CREATE OR ALTER VIEW vw_pbi_base_analisada AS
	SELECT
		ID,
		UF_PROVA,
		UF_ESCOLA,
		TIPO_ESCOLA,
		COR_RACA,
		FAIXA_DE_RENDA,
		INTERNET,
		NOTA_CIENCIAS_NATUREZA,
		NOTA_CIENCIAS_HUMANAS,
		NOTA_LINGUAGENS,
		NOTA_MATEMATICA,
		NOTA_REDACAO,
		PRESENCA_CIENCIAS_HUMANAS,
		PRESENCA_CIENCIAS_NATUREZA,
		PRESENCA_MATEMATICA,
		PRESENCA_LINGUAGENS,
		TREINEIRO,
        Media_Geral_ENEM,
        Presenca,
        Renda
	FROM ENEM_2023_TRATADO;
GO

-- Validação do codigo
SELECT TOP 100 *
FROM vw_pbi_base_analisada;

/*
===============================================================================
    1. Análise Socioeconômica
===============================================================================
*/

-- 1.1 Relação entre perfil socioeconômico, cor/raça e desempenho médio dos participantes.
CREATE OR ALTER VIEW vw_pbi_desempenho_perfil_socioeconomico AS
    WITH cte_perfil_socioeconomico_participantes AS (
        SELECT
            enem.COR_RACA,
            enem.FAIXA_DE_RENDA,
            enem.Media_Geral_ENEM
        FROM ENEM_2023_TRATADO AS enem
        WHERE enem.Presenca = 'Presenca_Total'
    )
    SELECT
        perfil.COR_RACA,
        perfil.FAIXA_DE_RENDA,
        renda.ID AS ID_Faixa_Renda,
        AVG(perfil.Media_Geral_ENEM) AS Media_Geral_ENEM,
        COUNT(*) AS Quantidade_Participantes,
        SUM(COUNT(*)) OVER (
            PARTITION BY perfil.COR_RACA
        ) AS Total_Participantes_Cor_Raca,
        ROUND(
            CAST(COUNT(*) AS DECIMAL(12, 2))
            / NULLIF(
                SUM(COUNT(*)) OVER (
                    PARTITION BY perfil.COR_RACA
                ),
                0
            ), -- Eu optei em remover o *100, para formatar como porcentagem no Power BI
            2
        ) AS Percentual_Representatividade
    FROM cte_perfil_socioeconomico_participantes AS perfil
    INNER JOIN DIM_FAIXA_DE_RENDA AS renda
        ON perfil.FAIXA_DE_RENDA = renda.Renda
    GROUP BY
        perfil.COR_RACA,
        perfil.FAIXA_DE_RENDA,
        renda.ID;
GO

-- Validação do codigo
SELECT TOP 100 *
FROM vw_pbi_desempenho_perfil_socioeconomico;

-- 1.2 Médias estaduais do ENEM com indicadores educacionais e econômicos por UF.
CREATE OR ALTER VIEW vw_pbi_desempenho_indicadores AS
    SELECT
        enem.UF_PROVA AS UF,
        estado.NO_ESTADO AS Estado,
        AVG(enem.Media_Geral_ENEM) AS Media_Geral_ENEM,
        SUM(
            CASE
                WHEN enem.Presenca = 'Presenca_Total' THEN 1
                ELSE 0
            END
        ) AS Participantes,
        estado.IDHM_EDUCACAO_2023 AS IDHM_Educacao,
        estado.IDEB_EM_2023 AS IDEB_Ensino_Medio,
        estado.PIB_PER_CAPITA AS PIB_Per_Capita
    FROM ENEM_2023_TRATADO AS enem
    INNER JOIN DIM_ESTADOS_INDICADORES AS estado
        ON enem.UF_PROVA = estado.SG_UF
    WHERE enem.Presenca = 'Presenca_Total'
    GROUP BY
        enem.UF_PROVA,
        estado.NO_ESTADO,
        estado.IDHM_EDUCACAO_2023,
        estado.IDEB_EM_2023,
        estado.PIB_PER_CAPITA;
GO

-- Validação do codigo
SELECT TOP 100 *
FROM vw_pbi_desempenho_indicadores;

-- 1.3 Desempenho médio por tipo de escola e faixa de renda.
CREATE OR ALTER VIEW vw_pbi_desempenho_escola_renda AS
    WITH cte_desempenho_escola_renda AS (
        SELECT
            enem.TIPO_ESCOLA,
            enem.FAIXA_DE_RENDA,
            enem.Media_Geral_ENEM
        FROM ENEM_2023_TRATADO AS enem
        WHERE
            enem.Presenca = 'Presenca_Total'
            AND enem.TIPO_ESCOLA <> 'Não Respondeu'
    )
    SELECT
        desempenho.TIPO_ESCOLA,
        desempenho.FAIXA_DE_RENDA,
        renda.ID AS ID_Faixa_Renda,
        COUNT(*) AS Quantidade_Participantes,
        ROUND(AVG(desempenho.Media_Geral_ENEM), 2) AS Media_Geral_ENEM
    FROM cte_desempenho_escola_renda AS desempenho
    INNER JOIN DIM_FAIXA_DE_RENDA AS renda
        ON desempenho.FAIXA_DE_RENDA = renda.Renda
    GROUP BY
        desempenho.TIPO_ESCOLA,
        desempenho.FAIXA_DE_RENDA,
        renda.ID;
GO

-- Validação do codigo
SELECT TOP 100 *
FROM vw_pbi_desempenho_escola_renda;

-- 1.4 Acesso à internet por UF, comparando volume de participantes e média geral.
CREATE OR ALTER VIEW vw_pbi_acesso_internet_uf AS
    WITH cte_acesso_internet_por_estado AS (
        SELECT
            enem.UF_PROVA AS UF,
            SUM(
                CASE
                    WHEN enem.INTERNET = 'Sim.' THEN 1
                    ELSE 0
                END
            ) AS Total_Com_Internet,
            AVG(
                CASE
                    WHEN enem.INTERNET = 'Sim.' THEN enem.Media_Geral_ENEM
                    ELSE NULL
                END
            ) AS Media_Com_Internet,
            SUM(
                CASE
                    WHEN enem.INTERNET = 'Não.' THEN 1
                    ELSE 0
                END
            ) AS Total_Sem_Internet,
            AVG(
                CASE
                    WHEN enem.INTERNET = 'Não.' THEN enem.Media_Geral_ENEM
                    ELSE NULL
                END
            ) AS Media_Sem_Internet,
            COUNT(*) AS Total_Participantes
        FROM ENEM_2023_TRATADO AS enem
        WHERE enem.Presenca = 'Presenca_Total'
        GROUP BY
            enem.UF_PROVA
    )
    SELECT
        acesso.UF,
        acesso.Total_Participantes,
        acesso.Total_Com_Internet,
        acesso.Media_Com_Internet,
        acesso.Total_Sem_Internet,
        acesso.Media_Sem_Internet
    FROM cte_acesso_internet_por_estado AS acesso;
GO

-- Validação do codigo
SELECT TOP 100 *
FROM vw_pbi_acesso_internet_uf;

/*
===============================================================================
    2. Análise de Abstenção
===============================================================================
*/

-- 2.1 Comparecimento e ausência dos inscritos por UF.
CREATE OR ALTER VIEW vw_pbi_participacao_ausencia_uf AS
    WITH cte_participacao_por_uf AS (
        SELECT
            enem.UF_PROVA AS UF,
            COUNT(*) AS Total_Inscritos,
            SUM(
                CASE
                    WHEN enem.Presenca = 'Ausencia_Total' THEN 1
                    ELSE 0
                END
            ) AS Total_Ausentes
        FROM ENEM_2023_TRATADO AS enem
        GROUP BY
            enem.UF_PROVA
    )
    SELECT
        participacao.UF,
        participacao.Total_Inscritos,
        participacao.Total_Ausentes,
        participacao.Total_Inscritos - participacao.Total_Ausentes AS Total_Participantes,
        ROUND(
            CAST(participacao.Total_Ausentes AS DECIMAL(12, 2))
            / NULLIF(participacao.Total_Inscritos, 0), 6 
            -- Eu optei em remover o *100, para formatar como porcentagem no Power BI
        ) AS Taxa_Ausencia,
        ROUND(
            SUM(participacao.Total_Ausentes) OVER()
            / NULLIF(SUM(participacao.Total_Inscritos) OVER(), 0),
            6
        ) AS Taxa_Ausencia_Nacional
    FROM cte_participacao_por_uf AS participacao;
GO

-- Validação do codigo
SELECT TOP 100 *
FROM vw_pbi_participacao_ausencia_uf;

-- 2.2 Composição socioeconômica dos participantes ausentes por cor/raça e faixa de renda.
CREATE OR ALTER VIEW vw_pbi_perfil_socioeconomico_ausentes AS
    WITH cte_perfil_socioeconomico_ausentes AS (
        SELECT
            enem.COR_RACA,
            enem.FAIXA_DE_RENDA
        FROM ENEM_2023_TRATADO AS enem
        WHERE enem.Presenca = 'Ausencia_Total'
    )
    SELECT
        ausentes.COR_RACA,
        ausentes.FAIXA_DE_RENDA,
        renda.ID AS ID_Faixa_Renda,
        COUNT(*) AS Quantidade_Ausentes,
        SUM(COUNT(*)) OVER (
            PARTITION BY ausentes.COR_RACA
        ) AS Total_Ausentes_Cor_Raca,
        ROUND(
            CAST(COUNT(*) AS DECIMAL(12, 2))
            / NULLIF(
                SUM(COUNT(*)) OVER (
                    PARTITION BY ausentes.COR_RACA
                ), 0
            ), 2
            -- Eu optei em remover o *100, para formatar como porcentagem no Power BI
        ) AS Percentual_Representatividade
    FROM cte_perfil_socioeconomico_ausentes AS ausentes
    INNER JOIN DIM_FAIXA_DE_RENDA AS renda
        ON ausentes.FAIXA_DE_RENDA = renda.Renda
    GROUP BY
        ausentes.COR_RACA,
        ausentes.FAIXA_DE_RENDA,
        renda.ID;
GO

-- Validação do codigo
SELECT TOP 100 *
FROM vw_pbi_perfil_socioeconomico_ausentes;

-- 2.3 Taxa de ausência considerando tipo de escola, faixa de renda e acesso à internet.
CREATE OR ALTER VIEW vw_pbi_abstencao_perfil AS
    WITH cte_abstencao_perfil AS (
        SELECT
            enem.TIPO_ESCOLA,
            enem.FAIXA_DE_RENDA,
            enem.INTERNET,
            COUNT(*) AS Total_Inscritos,
            SUM(
                CASE
                    WHEN enem.Presenca = 'Ausencia_Total' THEN 1
                    ELSE 0
                END
            ) AS Total_Ausentes
        FROM ENEM_2023_TRATADO AS enem
        WHERE enem.TIPO_ESCOLA <> 'Não Respondeu'
        GROUP BY
            enem.TIPO_ESCOLA,
            enem.FAIXA_DE_RENDA,
            enem.INTERNET
    )
    SELECT
        abstencao.TIPO_ESCOLA,
        abstencao.FAIXA_DE_RENDA,
        renda.ID AS ID_Faixa_Renda,
        abstencao.INTERNET,
        abstencao.Total_Inscritos,
        abstencao.Total_Ausentes,
        abstencao.Total_Inscritos - abstencao.Total_Ausentes AS Total_Presentes,
        ROUND(
            CAST(abstencao.Total_Ausentes AS DECIMAL(12, 2))
            / NULLIF(abstencao.Total_Inscritos, 0),
            2
            -- Eu optei em remover o *100, para formatar como porcentagem no Power BI
        ) AS Taxa_Ausencia
    FROM cte_abstencao_perfil AS abstencao
    INNER JOIN DIM_FAIXA_DE_RENDA AS renda
        ON abstencao.FAIXA_DE_RENDA = renda.Renda;
GO

-- Validação do codigo
SELECT TOP 100 *
FROM vw_pbi_abstencao_perfil;

-- 2.4 Candidatos que realizaram a prova em UF diferente da UF da escola e taxa de ausência.
CREATE OR ALTER VIEW vw_pbi_mobilidade_interestadual AS
    WITH cte_mobilidade_interestadual AS (
        SELECT
            enem.UF_ESCOLA AS UF_Escola,
            COUNT(*) AS Total_Inscritos,
            COUNT(
                CASE
                    WHEN enem.Presenca = 'Ausencia_Total' THEN 1
                END
            ) AS Total_Ausentes
        FROM ENEM_2023_TRATADO AS enem
        WHERE
            enem.UF_ESCOLA IS NOT NULL
            AND enem.UF_ESCOLA <> enem.UF_PROVA
        GROUP BY
            enem.UF_ESCOLA
    )
    SELECT
        mobilidade.UF_Escola,
        mobilidade.Total_Inscritos,
        mobilidade.Total_Ausentes,
        ROUND(
            CAST(mobilidade.Total_Ausentes AS DECIMAL(12, 2))
            / NULLIF(mobilidade.Total_Inscritos, 0),
            -- Eu optei em remover o *100, para formatar como porcentagem no Power BI
            2
        ) AS Taxa_Ausencia
    FROM cte_mobilidade_interestadual AS mobilidade;
GO

-- Validação do codigo
SELECT TOP 100 *
FROM vw_pbi_mobilidade_interestadual;

/*
===============================================================================
    3. Análise Comparativa entre Escola Pública e Privada
===============================================================================
*/

-- 3.1 Desempenho médio dos participantes presentes por tipo de escola.
CREATE OR ALTER VIEW vw_pbi_desempenho_tipo_escola AS
    SELECT
        enem.TIPO_ESCOLA,
        COUNT(*) AS Quantidade_Participantes,
        ROUND(AVG(enem.NOTA_CIENCIAS_NATUREZA), 2) AS Media_Nota_Ciencias_Natureza,
        ROUND(AVG(enem.NOTA_CIENCIAS_HUMANAS), 2) AS Media_Nota_Ciencias_Humanas,
        ROUND(AVG(enem.NOTA_LINGUAGENS), 2) AS Media_Nota_Linguagens,
        ROUND(AVG(enem.NOTA_MATEMATICA), 2) AS Media_Nota_Matematica,
        ROUND(AVG(enem.NOTA_REDACAO), 2) AS Media_Nota_Redacao,
        AVG(enem.Media_Geral_ENEM) AS Media_Geral_ENEM
    FROM ENEM_2023_TRATADO AS enem
    WHERE
        enem.Presenca = 'Presenca_Total'
        AND enem.TIPO_ESCOLA <> 'Não Respondeu'
    GROUP BY
        enem.TIPO_ESCOLA;
GO

-- Validação do codigo
SELECT TOP 100 *
FROM vw_pbi_desempenho_tipo_escola;

-- 3.2 Distribuição dos 10.000 melhores desempenhos entre escolas públicas e privadas.
CREATE OR ALTER VIEW vw_pbi_top10000_desempenho_escola AS
    WITH cte_ranking_desempenho AS (
        SELECT
            enem.TIPO_ESCOLA,
            enem.Media_Geral_ENEM,
            ROW_NUMBER() OVER (
                ORDER BY enem.Media_Geral_ENEM DESC
            ) AS Ranking
        FROM ENEM_2023_TRATADO AS enem
        WHERE
            enem.Presenca = 'Presenca_Total'
            AND enem.TIPO_ESCOLA <> 'Não Respondeu'
    )
    SELECT
        ranking.TIPO_ESCOLA,
        COUNT(*) AS Quantidade_Participantes
    FROM cte_ranking_desempenho AS ranking
    WHERE ranking.Ranking <= 10000
    GROUP BY
        ranking.TIPO_ESCOLA;
GO

-- Validação do codigo
SELECT TOP 100 *
FROM vw_pbi_top10000_desempenho_escola;

-- 3.3 Composição racial dos participantes entre escolas públicas e privadas.
CREATE OR ALTER VIEW vw_pbi_representatividade_racial_escola AS
    WITH cte_representatividade_racial_escolar AS (
        SELECT
            enem.COR_RACA,
            enem.TIPO_ESCOLA,
            COUNT(*) AS Quantidade_Participantes
        FROM ENEM_2023_TRATADO AS enem
        WHERE enem.TIPO_ESCOLA IN ('Pública', 'Privada')
        GROUP BY
            enem.COR_RACA,
            enem.TIPO_ESCOLA
    )
    SELECT
        representatividade.COR_RACA,
        representatividade.TIPO_ESCOLA,
        representatividade.Quantidade_Participantes,
        SUM(representatividade.Quantidade_Participantes) OVER (
            PARTITION BY representatividade.COR_RACA
        ) AS Total_Participantes_Cor_Raca,
        ROUND(
            CAST(representatividade.Quantidade_Participantes AS DECIMAL(12, 2))
            / NULLIF(
                SUM(representatividade.Quantidade_Participantes) OVER (
                    PARTITION BY representatividade.COR_RACA
                ), 0
                -- Eu optei em remover o *100, para formatar como porcentagem no Power BI
            ), 2
        ) AS Percentual_Representatividade
    FROM cte_representatividade_racial_escolar AS representatividade;
GO

-- Validação do codigo
SELECT TOP 100 *
FROM vw_pbi_representatividade_racial_escola;

-- 3.4 Desempenho por tipo de escola e faixa de renda (detalhado por área do conhecimento).
CREATE OR ALTER VIEW vw_pbi_desempenho_renda_escola AS
    WITH cte_desempenho_escola_renda AS (
        SELECT
            enem.FAIXA_DE_RENDA,
            enem.TIPO_ESCOLA,
            COUNT(*) AS Quantidade_Participantes,
            ROUND(AVG(enem.NOTA_CIENCIAS_NATUREZA), 2) AS Media_Ciencias_Natureza,
            ROUND(AVG(enem.NOTA_CIENCIAS_HUMANAS), 2) AS Media_Ciencias_Humanas,
            ROUND(AVG(enem.NOTA_LINGUAGENS), 2) AS Media_Linguagens,
            ROUND(AVG(enem.NOTA_MATEMATICA), 2) AS Media_Matematica,
            ROUND(AVG(enem.NOTA_REDACAO), 2) AS Media_Redacao,
            ROUND(AVG(enem.Media_Geral_ENEM), 2) AS Media_Geral_ENEM
        FROM ENEM_2023_TRATADO AS enem
        WHERE
            enem.Presenca = 'Presenca_Total'
            AND enem.TIPO_ESCOLA IN ('Pública', 'Privada')
        GROUP BY
            enem.FAIXA_DE_RENDA,
            enem.TIPO_ESCOLA
    )
    SELECT
        desempenho.TIPO_ESCOLA,
        desempenho.FAIXA_DE_RENDA,
        renda.ID AS ID_Faixa_Renda,
        desempenho.Quantidade_Participantes,
        desempenho.Media_Ciencias_Natureza,
        desempenho.Media_Ciencias_Humanas,
        desempenho.Media_Linguagens,
        desempenho.Media_Matematica,
        desempenho.Media_Redacao,
        desempenho.Media_Geral_ENEM
    FROM cte_desempenho_escola_renda AS desempenho
    INNER JOIN DIM_FAIXA_DE_RENDA AS renda
        ON desempenho.FAIXA_DE_RENDA = renda.Renda;
GO

-- Validação do codigo
SELECT TOP 100 *
FROM vw_pbi_desempenho_renda_escola;

-- 3.5 Desempenho médio por acesso à internet e tipo de escola.
CREATE OR ALTER VIEW vw_pbi_desempenho_internet_escola AS
    SELECT
        enem.TIPO_ESCOLA,
        enem.INTERNET,
        COUNT(*) AS Quantidade_Participantes,
        ROUND(AVG(enem.Media_Geral_ENEM), 2) AS Media_Geral_ENEM,
        ROUND(AVG(enem.NOTA_CIENCIAS_NATUREZA), 2) AS Media_CN,
        ROUND(AVG(enem.NOTA_CIENCIAS_HUMANAS), 2) AS Media_CH,
        ROUND(AVG(enem.NOTA_LINGUAGENS), 2) AS Media_LC,
        ROUND(AVG(enem.NOTA_MATEMATICA), 2) AS Media_MT,
        ROUND(AVG(enem.NOTA_REDACAO), 2) AS Media_Redacao
    FROM ENEM_2023_TRATADO AS enem
    WHERE
        enem.Presenca = 'Presenca_Total'
        AND enem.TIPO_ESCOLA <> 'Não Respondeu'
    GROUP BY
        enem.TIPO_ESCOLA,
        enem.INTERNET;
GO

-- Validação do codigo
SELECT TOP 100 *
FROM vw_pbi_desempenho_internet_escola
