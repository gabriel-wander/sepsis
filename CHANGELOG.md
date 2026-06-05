# Changelog — App Sepse

Formato baseado em Keep a Changelog. Datas no fuso do desenvolvimento.

## [Não publicado] — branch `claude/ios-sepsis-app-MyO2U`

### Adicionado
- App SwiftUI (iOS 16+) de apoio à decisão em sepse: cadastro/lista/edição de pacientes,
  6 scores (qSOFA, SOFA, SIRS, NEWS, APACHE II, MEDS), classificação sugerida, alertas clínicos,
  protocolo com fluxogramas e bundles 1/3/6 h, timeline de intervenções, medicações com regimes
  empíricos editáveis, calculadoras de dose, exportação PDF e persistência local offline.
- `AllergyChecker` (conflito/cautela) e `ClassificationAdvisor` (sugestão, não decisão).
- Acessibilidade: gravidade com texto (não só cor), Dynamic Type nos scores, rótulos VoiceOver.
- Ícone do app (placeholder 1024×1024 RGB, sem alpha) e `PrivacyInfo.xcprivacy` (offline, sem coleta).
- Testes: unitários (scores, serviços, modelo, casos de borda, 10 cenários clínicos) e de UI (XCUITest).
- CI no GitHub Actions (runner macOS/Xcode 16): build + testes a cada push.
- Documentação: `EVIDENCE_MAP.md`, `XCODE_GUIDE.md`, `RELEASE_CHECKLIST.md`.

### Segurança clínica (auditada — ver `EVIDENCE_MAP.md`)
- Triagem prioriza NEWS/SIRS; qSOFA só sinaliza risco e nunca exclui sepse.
- Antibiótico por probabilidade/gravidade (≤1 h choque/alta; ≤3 h possível; observar se baixa).
- Antimicrobianos editáveis (protocolo local/CCIH), não hardcoded.
- Fluidos 30 mL/kg individualizáveis; norepinefrina 1ª linha (PAM 65); corticoide só em choque (2024).
- Disclaimer de apoio à decisão em todas as telas de conduta.

### Pendente (depende do usuário)
- Arte final do ícone; validação do fluxo real em Xcode/iPhone; configuração de assinatura/TestFlight.
