<div align="center">

#   Análise de Desempenho no ENEM 2023
### Desigualdade Socioeconômica e Performance Educacional no Brasil

**SQL Server (T-SQL) · Power BI · 3,31 milhões de registros analisados**


*Um estudo orientado a dados sobre como renda, raça, acesso à internet e tipo de escola moldam o desempenho de 3,3 milhões de candidatos ao maior exame do Brasil.*

</div>

---

##   O problema do projeto

O ENEM é a principal porta de entrada para o ensino superior no Brasil. SISU, ProUni, FIES e vestibulares privados passam por ele. Mas **a nota reflete só o mérito individual, ou também a origem social do candidato?**

Este projeto trata, modela e analisa os microdados oficiais do INEP para responder isso com números, não com intuição e o resultado é uma diferença de **165 pontos** entre extremos de renda que nenhuma meritocracia explica sozinha.

##  Principais descobertas

| Fator analisado | Achado | Impacto |
|---|---|---|
| **Renda familiar** | Até 1 SM: 497 pts • Acima de 20 SM: 662 pts | **165 pontos** de diferença |
| **Acesso à internet** | Com internet: 546,8 pts • Sem internet: 484,4 pts | **62 pontos** de diferença |
| **Tipo de escola** | Privada: 616,1 pts • Pública: 515,8 pts | **100 pontos**, com 85,4% do Top 10.000 vindo da rede privada |
| **Raça/cor** | Brancos: 571,4 pts • Indígenas: 479,3 pts | **92 pontos**, mesmo controlando por renda |
| **Abstenção** | Taxa geral de 34,53% | Concentrada em baixa renda, rede pública e regiões Norte/Centro-Oeste |

>  **Insight central:** mesmo dentro da *mesma* faixa de renda, a diferença racial não desaparece pretos, pardos e brancos com renda equivalente ainda apresentam até 29 pontos de distância. A desigualdade no ENEM não é só uma questão financeira; é também estrutural.

Todos os números acima têm rastreabilidade completa até a query ou medida DAX que os gerou nenhum valor é estimado a olho.

##  Dashboard Power BI

O dashboard interativo traduz a análise em 4 páginas navegáveis, com filtros dinâmicos por UF, renda, raça/cor, tipo de escola, acesso à internet e situação de presença:

| Página | Foco |
|---|---|
| **1. Visão Geral** | Panorama nacional: inscritos, presentes, ausentes, médias por UF e por área do conhecimento |
| **2. Socioeconômica** | Cruzamento entre renda, internet, raça/cor e desempenho |
| **3. Abstenção** | Mapeamento da ausência por UF, renda e tipo de escola |
| **4. Pública x Privada** | Comparação direta entre redes de ensino, incluindo participação no Top 10.000 |

<p align="center">
  <img src="docs/images/dashboard_visao_geral.png" width="45%" alt="Dashboard - Visão Geral"/>
  <img src="docs/images/dashboard_socioeconomica.png" width="45%" alt="Dashboard - Socioeconômica"/>
  <br/>
  <img src="docs/images/dashboard_abstencao.png" width="45%" alt="Dashboard - Abstenção"/>
  <img src="docs/images/dashboard_publica_privada.png" width="45%" alt="Dashboard - Pública x Privada"/>
</p>

##  Arquitetura do projeto

O projeto segue uma separação clara entre **camada bruta**, **camada tratada** e **camada de consumo (BI)** uma prática que evita que o Power BI precise interpretar relacionamentos ambíguos automaticamente:

```
Microdados INEP (bruto)
        │
        ▼
┌───────────────────────────────────────┐
│         Pipeline SQL Server            │
│  01_Limpeza.sql                        │
│  02_Descodificacao.sql                 │
│  03_Campos_Complementares.sql          │
│  04_Tabela_Complementar.sql            │
│  05_Analise.sql                        │
└───────────────────────────────────────┘
        │
        ▼
   ENEM_2023_TRATADO  ──▶  Tabelas dimensão
   (DIM_FAIXA_DE_RENDA, DIM_ESTADOS_INDICADORES)
        │
        ▼
  9 Views analíticas (vw_pbi_*)
  camada de isolamento para o BI
        │
        ▼
     Power BI (4 páginas + medidas DAX)
```

**Por que essa arquitetura importa:** cada script SQL roda dentro de uma transação com validação pré-commit, e todas as views servem como uma camada de abstração entre o banco de dados e o Power BI o mesmo padrão usado em ambientes profissionais para manter modelos de dados seguros e escaláveis.

##  Stack técnico

- **SQL Server (T-SQL):** limpeza, decodificação, modelagem dimensional, views analíticas, controle transacional
- **Power BI:** modelagem de relacionamentos, medidas DAX, dashboard narrativo em 4 páginas
- **Fontes de dados externas:** IDHM (Atlas Brasil), IDEB (INEP), PIB per capita (IBGE). Usadas para enriquecer a análise regional

##  Pipeline de dados (resumo técnico)

1. **Limpeza:** remoção de treineiros, eliminados e notas zeradas → base final de 3,31M de ~3,93M de registros originais
2. **Decodificação:** conversão de códigos numéricos em categorias legíveis (raça/cor, renda, internet, tipo de escola)
3. **Campos complementares:** criação de `Media_Geral_ENEM` e `Presenca` (Presença Total / Ausência Parcial / Ausência Total), com correção de escala em notas importadas com vírgula decimal
4. **Tabelas complementares:** dimensões auxiliares (`DIM_FAIXA_DE_RENDA`, `DIM_ESTADOS_INDICADORES`) para ordenação e enriquecimento regional
5. **Análise:** consolidação em views temáticas (socioeconômica, abstenção, redes de ensino, participação por UF, representatividade racial, entre outras)

Todas as etapas usam `NULLIF` para proteção padronizada contra nulos e contagens de conferência após cada operação.

##  Estrutura do repositório

```
├── sql/
│   ├── 01_Limpeza.sql
│   ├── 02_Descodificacao.sql
│   ├── 03_Campos_Complementares.sql
│   ├── 04_Tabela_Complementar.sql
│   └── 05_Analise.sql
├── dashboard/
│   └── ENEM_2023.pbix
├── docs/
│   ├── Analise_ENEM_2023_Relatorio.pdf
│   └── images/
└── README.md
```

##  Limitações

Os resultados mostram **correlação, não causalidade**. Variáveis como rotina de estudos, acesso a cursinho e distância até o local de prova não estão disponíveis na base. A remoção de treineiros e eliminados, embora necessária para a integridade da análise, significa que os números refletem apenas quem tinha intenção efetiva de ingressar no ensino superior.

##  Próximos passos

- [ ] Modelo preditivo de desempenho
- [ ] Análise estatística aprofundada em Python
- [ ] Aprofundamento por região/estado
- [ ] Comparação ENEM 2023 vs. edições anteriores

##  Relatório Completo

   [Relatório completo (PDF)](docs/Analise_ENEM_2023_Relatorio.pdf)

## Feito por:

**João Pedro Beluso Lopes**
Analista de Dados em Formação 

[LinkedIn](https://www.linkedin.com/in/joão-beluso) · [joaopedrobeluso@gmail.com](mailto:joaopedrobeluso@gmail.com)

---

<div align="center">
<sub>Dados públicos: Microdados do ENEM 2023, disponibilizados pelo INEP.</sub>
</div>
