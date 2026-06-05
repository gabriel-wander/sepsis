# Evidence Map — App de Apoio à Decisão em Sepse

> **Natureza do app:** ferramenta de **apoio à decisão clínica** para médicos. **Não** é
> sistema autônomo de diagnóstico ou prescrição. Toda conduta exige confirmação por
> julgamento clínico, protocolos locais e equipe assistente.

**Fontes principais**
- **SSC 2021** — Surviving Sepsis Campaign: International Guidelines for Management of Sepsis and Septic Shock 2021 (Evans L, et al. Crit Care Med. 2021;49(11):e1063–e1143).
- **Sepsis-3** — Singer M, et al. JAMA 2016;315(8):801–810; Seymour CW, et al. JAMA 2016;315(8):762–774.
- **Corticoides 2024** — atualização focada em corticosteroides na sepse/choque séptico (guideline de 2024). Usada **somente** para a recomendação de corticosteroide.
- **NEWS** — Royal College of Physicians; meta-análise Qiu X, et al. Expert Rev Anti Infect Ther. 2023.

| # | Funcionalidade | Regra clínica implementada | Fonte | Força da recomendação | Observações de segurança | Depende de protocolo local? |
|---|----------------|----------------------------|-------|-----------------------|--------------------------|------------------------------|
| 1 | Triagem (fora da UTI) | Priorizar **NEWS / MEWS / SIRS + avaliação clínica**. qSOFA **não** é ferramenta única de triagem. | SSC 2021; Qiu 2023 | SSC 2021: sugere **não** usar qSOFA isolado vs. SIRS/NEWS/MEWS para triagem | qSOFA **negativo nunca exclui sepse**. qSOFA exibido apenas como alerta/prognóstico. | Não |
| 2 | qSOFA | Calculado como sinalizador de risco/prognóstico em paciente com infecção suspeita fora da UTI. | Sepsis-3; SSC 2021 | Fraca para triagem | Mensagem fixa: qSOFA não exclui sepse; não substitui avaliação clínica. | Não |
| 3 | Diagnóstico de sepse | Suspeita/confirmação de infecção **+** disfunção orgânica = **aumento do SOFA ≥ 2** sobre o basal. | Sepsis-3 | Forte (definição consensual) | SOFA basal presumido 0 se desconhecido — sinalizar incerteza ao usuário. | Não |
| 4 | Choque séptico | Necessidade de **vasopressor** para PAM ≥ 65 mmHg **após ressuscitação volêmica adequada** **+ lactato > 2 mmol/L**. | Sepsis-3; SSC 2021 | Forte | Classificação confirmada pelo médico; app sugere, não decide. | Não |
| 5 | Tempo de antibiótico | **Choque/alta probabilidade:** ATB imediato, idealmente ≤ 1 h. **Possível sepse sem choque:** investigação rápida, ATB ≤ 3 h se a suspeita persistir. **Baixa probabilidade sem choque:** permitir observação/reavaliação, **não forçar** ATB. | SSC 2021 | Forte (choque/≤1h); fraca (sem choque/≤3h) | Não disparar alerta de "atraso" quando a probabilidade for baixa sem choque. | Parcial (definição de probabilidade é clínica) |
| 6 | Esquemas antimicrobianos | Estrutura **editável** por regime institucional/CCIH. Considerar antibiograma local, alergias, foco suspeito, função renal, função hepática, risco de MRSA/MDR/fungo. | SSC 2021 | Forte (amplo espectro precoce no choque) | **Nenhum esquema é hardcoded como universal.** Exemplos vêm rotulados como "substituir por protocolo institucional". | **Sim (essencial)** |
| 7 | Fluidos | **30 mL/kg de cristaloide** como **referência inicial** para hipoperfusão/choque; apresentar como **individualizável** e exigir **reavaliação dinâmica**. | SSC 2021 | Fraca (qualidade baixa) | Cautela explícita em **IC, DRC, cirrose, idosos, risco de congestão**. Preferir cristaloide balanceado. | Parcial |
| 8 | Vasopressores | **Norepinefrina 1ª linha**; alvo inicial **PAM 65 mmHg**; **vasopressina/epinefrina** adjuvantes; **dobutamina** apenas se hipoperfusão persistente com PAM adequada e suspeita de disfunção miocárdica. | SSC 2021 | Forte (norepi, PAM 65); fraca (adjuvantes) | Doses como referência; titular conforme resposta. | Parcial (diluições locais) |
| 9 | Corticosteroides | Sugerir **apenas em choque séptico com necessidade persistente de vasopressor**. **Evitar** regimes de alta dose/curta duração. **Não** recomendar para sepse sem choque. | Corticoides 2024; SSC 2021 | Fraca | Hidrocortisona dose baixa (≈200 mg/dia). Decisão individualizada. | Parcial |
| 10 | Controle de foco | Identificar e controlar o foco o mais precoce possível após estabilização. | SSC 2021 | Boas práticas | Intervenção definida pela equipe assistente. | Não |
| 11 | Desescalonamento | Reavaliar em 48–72 h com culturas; desescalonar; reavaliar vasopressores e corticoide. | SSC 2021 | Forte (desescalonamento) | Ajuste por antibiograma local. | Sim |
| 12 | Disclaimer de conduta | Todas as telas de conduta exibem: *"Apoio à decisão. Confirmar com julgamento clínico, protocolos locais e equipe assistente."* | Política do app | — | Banner não dispensável nas telas de conduta. | Não |

## Pontos que dependem de protocolo local (resumo)
- Seleção de antimicrobiano empírico (CCIH, antibiograma, foco, alergias, função renal/hepática, MRSA/MDR/fungo).
- Definição clínica de "probabilidade de infecção/sepse".
- Volume e ritmo de fluidos em populações de risco de congestão.
- Diluições/concentrações de vasopressores.
- Critérios institucionais de desescalonamento e duração de antibiótico.
