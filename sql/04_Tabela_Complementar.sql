
-- 1. Criação da dimensão de indicadores estaduais

    CREATE TABLE DIM_ESTADOS_INDICADORES (
        ID                  INT             NOT NULL PRIMARY KEY,
        SG_UF               CHAR(2)         NOT NULL UNIQUE,
        NO_ESTADO           VARCHAR(50)     NOT NULL,
        IDHM_EDUCACAO_2023  DECIMAL(5, 3),
        IDHM_RENDA_2023     DECIMAL(5, 3),
        IDEB_EM_2023        DECIMAL(3, 1),
        PIB_PER_CAPITA      DECIMAL(10, 2)
    );


    -- Inserção dos dados na dimensão de indicadores estaduais

    INSERT INTO DIM_ESTADOS_INDICADORES VALUES
        (1,  'AC', 'Acre',                 0.722, 0.665, 4.0, 31675.60),
        (2,  'AL', 'Alagoas',              0.738, 0.669, 4.1, 28675.84),
        (3,  'AP', 'Amapá',                0.772, 0.718, 3.8, 38187.09),
        (4,  'AM', 'Amazonas',             0.787, 0.678, 3.8, 41047.91),
        (5,  'BA', 'Bahia',                0.714, 0.673, 3.9, 30476.54),
        (6,  'CE', 'Ceará',                0.788, 0.674, 4.3, 26405.96),
        (7,  'DF', 'Distrito Federal',     0.860, 0.841, 4.2, 129790.44),
        (8,  'ES', 'Espírito Santo',       0.791, 0.755, 4.8, 54732.78),
        (9,  'GO', 'Goiás',                0.808, 0.763, 4.8, 47721.56),
        (10, 'MA', 'Maranhão',             0.744, 0.648, 3.8, 22020.63),
        (11, 'MS', 'Mato Grosso do Sul',   0.772, 0.764, 4.4, 66884.75),
        (12, 'MT', 'Mato Grosso',          0.784, 0.761, 4.0, 74620.05),
        (13, 'MG', 'Minas Gerais',         0.790, 0.753, 4.2, 47321.23),
        (14, 'PB', 'Paraíba',              0.722, 0.698, 4.4, 24395.17),
        (15, 'PR', 'Paraná',               0.809, 0.768, 4.0, 58624.33),
        (16, 'PA', 'Pará',                 0.726, 0.692, 4.9, 31347.59),
        (17, 'PE', 'Pernambuco',           0.765, 0.669, 4.5, 29857.27),
        (18, 'PI', 'Piauí',                0.731, 0.699, 4.5, 24736.15),
        (19, 'RJ', 'Rio de Janeiro',       0.812, 0.788, 3.7, 73052.55),
        (20, 'RN', 'Rio Grande do Norte',  0.722, 0.702, 3.7, 30804.91),
        (21, 'RS', 'Rio Grande do Sul',    0.770, 0.784, 4.2, 59736.20),
        (22, 'RO', 'Rondônia',             0.743, 0.721, 4.2, 48353.38),
        (23, 'RR', 'Roraima',              0.782, 0.711, 3.5, 39460.54),
        (24, 'SC', 'Santa Catarina',       0.800, 0.782, 4.2, 67459.74),
        (25, 'SP', 'São Paulo',            0.851, 0.795, 4.5, 77566.27),
        (26, 'SE', 'Sergipe',              0.720, 0.682, 4.0, 27518.80),
        (27, 'TO', 'Tocantins',            0.791, 0.723, 4.2, 42553.36);
    
    -- Consulta de validação da tabela DIM_ESTADOS_INDICADORES

    SELECT
        *
    FROM 
        DIM_ESTADOS_INDICADORES;


-- 2. Criação da dimensão de faixa de renda

    CREATE TABLE DIM_FAIXA_DE_RENDA (
        ID      INT             NOT NULL PRIMARY KEY IDENTITY(1, 1),
        Renda   VARCHAR(150)    NOT NULL UNIQUE
    );

   --Inserção das faixas de renda

   INSERT INTO DIM_FAIXA_DE_RENDA (Renda)
   VALUES
        ('Nenhuma Renda.'),
        ('Até R$ 1.320,00.'),
        ('De R$ 1.320,01 até R$ 1.980,00.'),
        ('De R$ 1.980,01 até R$ 2.640,00.'),
        ('De R$ 2.640,01 até R$ 3.300,00.'),
        ('De R$ 3.300,01 até R$ 3.960,00.'),
        ('De R$ 3.960,01 até R$ 5.280,00.'),
        ('De R$ 5.280,01 até R$ 6.600,00.'),
        ('De R$ 6.600,01 até R$ 7.920,00.'),
        ('De R$ 7.920,01 até R$ 9.240,00.'),
        ('De R$ 9.240,01 até R$ 10.560,00.'),
        ('De R$ 10.560,01 até R$ 11.880,00.'),
        ('De R$ 11.880,01 até R$ 13.200,00.'),
        ('De R$ 13.200,01 até R$ 15.840,00.'),
        ('De R$ 15.840,01 até R$ 19.800,00.'),
        ('De R$ 19.800,01 até R$ 26.400,00.'),
        ('Acima de R$ 26.400,00.');


        -- Consulta de validação da tabela DIM_FAIXA_DE_RENDA

        SELECT
            *
        FROM 
            DIM_FAIXA_DE_RENDA
        ORDER BY
            ID;
