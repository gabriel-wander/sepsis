# Sepse — App de Apoio à Decisão Clínica (iOS)

Aplicativo iOS (Swift/SwiftUI) de **apoio à decisão clínica** para diagnóstico e tratamento de
sepse em pacientes adultos hospitalizados, baseado na **Surviving Sepsis Campaign 2021**,
nas definições **Sepsis-3** e na **atualização de corticosteroides de 2024**.

> ⚠️ **Esta é uma ferramenta de apoio à decisão para médicos. Não é um sistema autônomo de
> diagnóstico ou prescrição.** Toda conduta deve ser confirmada com julgamento clínico,
> protocolos locais e equipe assistente.

## Funcionalidades

- **Cadastro de pacientes** — dados demográficos, comorbidades, colonização por MDR, alergias,
  função renal/hepática, ambiente de atendimento e local de aquisição da infecção.
- **Scores** — qSOFA, SOFA, SIRS, NEWS, APACHE II e MEDS, com cálculo em tempo real,
  interpretação automática, histórico e gráfico de evolução.
- **Protocolos** — 5 fluxogramas interativos (triagem, ressuscitação, vasopressores,
  controle de foco, desescalonamento), checklist de bundles (1/3/6 h) e timer desde o
  reconhecimento de sepse.
- **Medicações** — regimes empíricos **editáveis** (protocolo institucional/CCIH), banco de
  antimicrobianos de referência e calculadoras de dose (fluidos, vasopressores, ATB por peso,
  ajuste por função renal).
- **Evolução** — registro temporal de intervenções, linha do tempo e gráficos de scores.
- **Exportação** — relatório PDF compartilhável.
- **Offline** — persistência local em JSON (sem necessidade de rede).

## Regras clínicas de segurança implementadas

Resumo (detalhes e fontes em [`EVIDENCE_MAP.md`](EVIDENCE_MAP.md)):

1. **Triagem** prioriza NEWS/MEWS/SIRS + avaliação clínica. **qSOFA não é triagem única** e um
   qSOFA negativo **nunca exclui sepse** — aparece apenas como sinalizador de risco/prognóstico.
2. **Sepse** = infecção suspeita/confirmada + disfunção orgânica (**SOFA ≥ 2** sobre o basal).
   **Choque séptico** = vasopressor para PAM ≥ 65 mmHg após ressuscitação adequada + lactato > 2 mmol/L.
3. **Antibiótico por probabilidade/gravidade:** choque/alta probabilidade ≤ 1 h; possível sem
   choque ≤ 3 h; baixa probabilidade sem choque → observação/reavaliação (não forçar).
4. **Esquemas antimicrobianos editáveis**, nunca hardcoded como universais.
5. **Fluidos** 30 mL/kg como referência inicial individualizável, com reavaliação dinâmica e
   cautela em IC/DRC/cirrose/idosos/congestão.
6. **Vasopressores:** norepinefrina 1ª linha; PAM 65; vasopressina/epinefrina adjuvantes;
   dobutamina só em disfunção miocárdica.
7. **Corticosteroides (2024):** somente em choque séptico com vasopressor persistente; dose baixa;
   evitar alta dose/curta duração; não usar em sepse sem choque.
8. **Disclaimer de apoio à decisão** visível em todas as telas de conduta.

## Estrutura do projeto

```
SepseApp/
├── SepseApp.xcodeproj/         # Projeto Xcode (grupo sincronizado com o sistema de arquivos)
└── SepseApp/
    ├── SepseAppApp.swift        # Entry point
    ├── Models/                  # Patient, enums, scores, antimicrobianos, protocolos, constantes
    ├── Persistence/             # DataStore (JSON local, offline)
    ├── Scores/                  # Calculadoras: qSOFA, SOFA, SIRS, NEWS, APACHE II, MEDS
    ├── Services/                # Banco de antimicrobianos, doses, protocolos, alertas, PDF
    ├── Views/                   # Telas SwiftUI (lista, perfil, scores, protocolo, medicações, evolução)
    └── Resources/               # Asset catalog
```

## Build

Requer **Xcode 16+** (usa grupos sincronizados com o sistema de arquivos) e **iOS 16+**.

```bash
open SepseApp/SepseApp.xcodeproj
```

Selecione o target **SepseApp** e um simulador iOS, então compile e execute (⌘R).

## Documentação

- [`EVIDENCE_MAP.md`](EVIDENCE_MAP.md) — funcionalidade → regra clínica → fonte → força → segurança.
- [`XCODE_GUIDE.md`](XCODE_GUIDE.md) — abrir, compilar (⌘B), rodar (⌘R), testar (⌘U), iPhone.
- [`RELEASE_CHECKLIST.md`](RELEASE_CHECKLIST.md) — assinatura, ícone, privacidade, TestFlight/App Store.
- [`CHANGELOG.md`](CHANGELOG.md) — histórico de mudanças.

CI: GitHub Actions (`.github/workflows/ios.yml`) compila e roda os testes (unitários + UI) em
runner macOS/Xcode 16 a cada push.

## Privacidade e segurança

- Dados armazenados localmente no dispositivo (Documentos do app), em JSON.
- Sem coleta ou transmissão para servidores externos.
- Para produção: habilitar Data Protection/criptografia em repouso, autenticação biométrica e
  conformidade com HIPAA/LGPD antes do uso clínico real.
