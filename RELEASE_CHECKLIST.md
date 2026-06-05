# Checklist de Release — App Sepse (TestFlight / App Store)

> Pré-requisito: CI verde (build + testes). Ver `XCODE_GUIDE.md` para build/teste local.

## 1. Identidade e assinatura
- [ ] Definir **Bundle ID** de produção (atual: `com.sepseapp.SepseApp`) no Apple Developer.
- [ ] Target `SepseApp` ▸ **Signing & Capabilities** ▸ Team + *Automatically manage signing*.
- [ ] Conferir `MARKETING_VERSION` (1.0) e `CURRENT_PROJECT_VERSION` (build) a cada envio.

## 2. Ícone e apresentação
- [ ] Adicionar ícone 1024×1024 em `Assets.xcassets/AppIcon` (hoje há apenas o slot vazio).
- [ ] Launch screen (gerada automaticamente via `INFOPLIST_KEY_UILaunchScreen_Generation`).
- [ ] Capturas de tela para a ficha da App Store (iPhone 6.7" e 6.1").

## 3. Privacidade e conformidade
- [x] **Manifesto de privacidade** `PrivacyInfo.xcprivacy` (sem rastreamento, sem coleta — app offline).
- [ ] Preencher **App Privacy** no App Store Connect coerente com o manifesto (nenhum dado coletado).
- [ ] **Encryption compliance**: app usa apenas criptografia padrão do sistema → declarar isenção
      (`ITSAppUsesNonExemptEncryption = NO`) no envio.
- [ ] **HIPAA/LGPD** (uso clínico real): habilitar Data Protection/criptografia em repouso,
      autenticação biométrica para abrir o app, e política de privacidade.
- [ ] **Aviso regulatório**: descrever como **ferramenta de apoio à decisão** (não dispositivo
      diagnóstico autônomo). Avaliar enquadramento como SaMD junto à ANVISA/FDA conforme uso pretendido.

## 4. Qualidade
- [ ] `⌘U` verde localmente; CI verde na PR.
- [ ] Testar em dispositivo físico (ver `XCODE_GUIDE.md`).
- [ ] Passada de acessibilidade: VoiceOver no fluxo principal, Dynamic Type em XXL.
- [ ] Revisar textos clínicos e disclaimers em todas as telas de conduta.

## 5. Envio
- [ ] **Product ▸ Archive** (configuração Release).
- [ ] Validar e enviar ao **App Store Connect** (Organizer ou `xcodebuild -exportArchive`).
- [ ] Distribuir no **TestFlight** (teste interno) antes da revisão da App Store.
- [ ] Notas de versão mencionando que é apoio à decisão e exige protocolos locais/CCIH.

## 6. Pós-release
- [ ] Monitorar crashes (Xcode Organizer).
- [ ] Plano de atualização do conteúdo clínico conforme novas diretrizes (atualizar `EVIDENCE_MAP.md`).
