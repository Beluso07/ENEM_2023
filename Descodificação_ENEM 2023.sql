
    -- 1. Descodificação da variável COR_RACA	
		
        -- Inicialmente, foi necessário expandir a quantidade de caracteres permitidos e do tipo de dado aceito
        ALTER TABLE ENEM_2023_TRATADO
        ALTER COLUMN COR_RACA VARCHAR(100);

        UPDATE ENEM_2023_TRATADO
        SET COR_RACA =
            CASE
                WHEN COR_RACA = '0' THEN 'Não Declarado'
                WHEN COR_RACA = '1' THEN 'Branca'
                WHEN COR_RACA = '2' THEN 'Preta'
                WHEN COR_RACA = '3' THEN 'Parda'
                WHEN COR_RACA = '4' THEN 'Amarela'
                WHEN COR_RACA = '5' THEN 'Indígena'
                ELSE 'Não dispõe da informação'
            END;

   
-- 2. Descodificação da variável FAIXA_DE_RENDA - Faixas de renda familiar.
      
    -- Inicialmente, foi necessário expandir a quantidade de caracteres permitidos 
        ALTER TABLE ENEM_2023_TRATADO
        ALTER COLUMN FAIXA_DE_RENDA VARCHAR(150);

        UPDATE ENEM_2023_TRATADO
        SET FAIXA_DE_RENDA =
            CASE
                WHEN FAIXA_DE_RENDA = 'A' THEN 'Nenhuma Renda.'
                WHEN FAIXA_DE_RENDA = 'B' THEN 'Até R$ 1.320,00.'
                WHEN FAIXA_DE_RENDA = 'C' THEN 'De R$ 1.320,01 até R$ 1.980,00.'
                WHEN FAIXA_DE_RENDA = 'D' THEN 'De R$ 1.980,01 até R$ 2.640,00.'
                WHEN FAIXA_DE_RENDA = 'E' THEN 'De R$ 2.640,01 até R$ 3.300,00.'
                WHEN FAIXA_DE_RENDA = 'F' THEN 'De R$ 3.300,01 até R$ 3.960,00.'
                WHEN FAIXA_DE_RENDA = 'G' THEN 'De R$ 3.960,01 até R$ 5.280,00.'
                WHEN FAIXA_DE_RENDA = 'H' THEN 'De R$ 5.280,01 até R$ 6.600,00.'
                WHEN FAIXA_DE_RENDA = 'I' THEN 'De R$ 6.600,01 até R$ 7.920,00.'
                WHEN FAIXA_DE_RENDA = 'J' THEN 'De R$ 7.920,01 até R$ 9.240,00.'
                WHEN FAIXA_DE_RENDA = 'K' THEN 'De R$ 9.240,01 até R$ 10.560,00.'
                WHEN FAIXA_DE_RENDA = 'L' THEN 'De R$ 10.560,01 até R$ 11.880,00.'
                WHEN FAIXA_DE_RENDA = 'M' THEN 'De R$ 11.880,01 até R$ 13.200,00.'
                WHEN FAIXA_DE_RENDA = 'N' THEN 'De R$ 13.200,01 até R$ 15.840,00.'
                WHEN FAIXA_DE_RENDA = 'O' THEN 'De R$ 15.840,01 até R$ 19.800,00.'
                WHEN FAIXA_DE_RENDA = 'P' THEN 'De R$ 19.800,01 até R$ 26.400,00.'
                WHEN FAIXA_DE_RENDA = 'Q' THEN 'Acima de R$ 26.400,00.'
                ELSE 'Não dispõe da informação'
            END;


-- 3. Descodificação da variável INTERNET - Internet
 
    UPDATE ENEM_2023_TRATADO
    SET INTERNET =
    CASE
        WHEN INTERNET = 'A' THEN 'Não.'
        WHEN INTERNET = 'B' THEN 'Sim.'
        ELSE 'Não informado'
    END 

    
-- 4. Descodificação da variável TIPO_ESCOLA

    -- Inicialmente, foi necessário expandir a quantidade de caracteres permitidos e do tipo de dado aceito
        ALTER TABLE ENEM_2023_TRATADO
        ALTER COLUMN TIPO_ESCOLA VARCHAR(100);

        UPDATE ENEM_2023_TRATADO
        SET TIPO_ESCOLA =
            CASE
                WHEN TIPO_ESCOLA = '1' THEN 'Não Respondeu'
                WHEN TIPO_ESCOLA = '2' THEN 'Pública'
                WHEN TIPO_ESCOLA = '3' THEN 'Privada'
                ELSE 'Não dispõe da informação'
            END;