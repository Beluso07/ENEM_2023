
-- 1- Adicionei a tabela a coluna de Média_Geral_ENEM, para facilitar.

	ALTER TABLE ENEM_2023_TRATADO
	ADD Media_Geral_ENEM DECIMAL(6,2);

	UPDATE ENEM_2023_TRATADO
		SET 
           Media_Geral_ENEM = 
           (NOTA_CIENCIAS_NATUREZA + NOTA_CIENCIAS_HUMANAS + NOTA_LINGUAGENS + NOTA_MATEMATICA + NOTA_REDACAO) / 5.0
        WHERE
            NOTA_CIENCIAS_NATUREZA IS NOT NULL
            AND NOTA_CIENCIAS_HUMANAS IS NOT NULL
            AND NOTA_LINGUAGENS IS NOT NULL
            AND NOTA_MATEMATICA IS NOT NULL
            AND NOTA_REDACAO IS NOT NULL;
    
    SELECT
			@@ROWCOUNT AS Registros_Media_ENEM;

-- 2- Adicionei a tabela a coluna de Presença, para facilitar.
    
    ALTER TABLE ENEM_2023_TRATADO
	ADD Presenca VARCHAR(50);

	UPDATE ENEM_2023_TRATADO
	SET Presenca =
	CASE WHEN PRESENCA_CIENCIAS_HUMANAS = 0
	      AND PRESENCA_CIENCIAS_NATUREZA = 0
		  AND PRESENCA_MATEMATICA = 0
		  AND PRESENCA_LINGUAGENS = 0

	THEN 'Ausencia_Total'

	-- Apenas a presença no primeiro dia ou no segundo.
		 WHEN PRESENCA_CIENCIAS_HUMANAS = 0
	      OR PRESENCA_CIENCIAS_NATUREZA = 0
		  OR PRESENCA_MATEMATICA = 0
		  OR PRESENCA_LINGUAGENS = 0
		  OR PRESENCA_MATEMATICA IS NULL
		  OR PRESENCA_CIENCIAS_NATUREZA IS NULL
          OR PRESENCA_LINGUAGENS IS NULL
          OR PRESENCA_CIENCIAS_HUMANAS IS NULL
	THEN 'Ausencia_Parcial'

	ELSE 'Presenca_Total'

	END;

    SELECT
			@@ROWCOUNT AS Registros_Presenca;

-- 3- Adicionei a tabela a coluna de Status redação, para facilitar.

    ALTER TABLE ENEM_2023_TRATADO
    ADD Status_Redacao VARCHAR(50);

    UPDATE ENEM_2023_TRATADO
    SET Status_Redacao =
    CASE WHEN NOTA_REDACAO IS NULL THEN 'Redacao_Invalida'
         WHEN NOTA_REDACAO = 0 THEN 'Redacao_Zerada'
         ELSE 'Redacao_Valida' END;
     
     SELECT
			@@ROWCOUNT AS Registros_Redacao;

-- 4- Adicionei a tabela um agrupamento de faixa de renda, para facilitar a vizualização no Power BI.

    ALTER TABLE ENEM_2023_TRATADO
    ADD RENDA VARCHAR(50);

    UPDATE ENEM_2023_TRATADO
    SET RENDA = 
        CASE 
            WHEN FAIXA_DE_RENDA = 'Nenhuma Renda.' 
              OR FAIXA_DE_RENDA = 'Até R$ 1.320,00.' 
                THEN 'Até 1 SM'

            WHEN FAIXA_DE_RENDA = 'De R$ 1.320,01 até R$ 1.980,00.' 
              OR FAIXA_DE_RENDA = 'De R$ 1.980,01 até R$ 2.640,00.' 
                THEN 'De 1 a 2 SM'

            WHEN FAIXA_DE_RENDA = 'De R$ 2.640,01 até R$ 3.300,00.' 
              OR FAIXA_DE_RENDA = 'De R$ 3.300,01 até R$ 3.960,00.' 
              OR FAIXA_DE_RENDA = 'De R$ 3.960,01 até R$ 5.280,00.' 
              OR FAIXA_DE_RENDA = 'De R$ 5.280,01 até R$ 6.600,00.' 
                THEN 'De 2 a 5 SM'

            WHEN FAIXA_DE_RENDA = 'De R$ 6.600,01 até R$ 7.920,00.' 
              OR FAIXA_DE_RENDA = 'De R$ 7.920,01 até R$ 9.240,00.' 
              OR FAIXA_DE_RENDA = 'De R$ 9.240,01 até R$ 10.560,00.' 
              OR FAIXA_DE_RENDA = 'De R$ 10.560,01 até R$ 11.880,00.' 
              OR FAIXA_DE_RENDA = 'De R$ 11.880,01 até R$ 13.200,00.' 
                THEN 'De 5 a 10 SM'

            WHEN FAIXA_DE_RENDA = 'De R$ 13.200,01 até R$ 15.840,00.' 
              OR FAIXA_DE_RENDA = 'De R$ 15.840,01 até R$ 19.800,00.' 
              OR FAIXA_DE_RENDA = 'De R$ 19.800,01 até R$ 26.400,00.' 
                THEN 'De 10 a 20 SM'

            WHEN FAIXA_DE_RENDA = 'Acima de R$ 26.400,00.' 
                THEN 'Acima de 20 SM'

            ELSE 'Não Informado'
        END;
    
    SELECT
			@@ROWCOUNT AS Registros_Renda;
