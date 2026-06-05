# Guia de build, testes e execução no Xcode

> Requisitos: **Xcode 16+** (o projeto usa grupos sincronizados com o sistema de arquivos),
> **iOS 16+** no simulador ou dispositivo.

## 1. Abrir o projeto

```bash
open SepseApp/SepseApp.xcodeproj
```

Ou no Xcode: **File ▸ Open…** e selecione `SepseApp/SepseApp.xcodeproj`.

## 2. Selecionar o scheme

No topo da janela, ao lado dos botões ▶︎/◼︎, selecione o scheme **SepseApp** (já vem
compartilhado no repositório) e um destino, por exemplo **iPhone 15 (simulator)**.

## 3. Compilar (⌘B)

Menu **Product ▸ Build** ou **⌘B**.

- Não há dependências externas (sem CocoaPods/SPM). A primeira build pode levar ~1 min.
- Se aparecer erro de assinatura ao rodar em **dispositivo físico**, vá em
  **Signing & Capabilities** do target `SepseApp`, marque *Automatically manage signing* e
  selecione seu Team. (Para simulador não é necessário.)

## 4. Rodar o app (⌘R)

**Product ▸ Run** ou **⌘R**. O app abre na lista de pacientes.

### Fluxo mínimo para validar
1. Toque em **+** → preencha nome/idade/peso → **Salvar**.
2. Abra o paciente → aba **Scores** → escolha um score → ajuste valores → **Registrar resultado**.
3. Aba **Perfil** → ajuste a **Classificação** (veja a sugestão do advisor e os alertas).
4. Aba **Protocolo** → **Iniciar protocolo** (marca o reconhecimento e cria os bundles 1/3/6 h)
   → marque itens do bundle.
5. Aba **Evolução** → **+** → registre intervenções (lactato, culturas, antibiótico, fluido,
   vasopressor) com timestamp.
6. Aba **Perfil** → menu **…** → **Exportar PDF** → compartilhar.

## 5. Rodar os testes (⌘U)

**Product ▸ Test** ou **⌘U**. Executa o target **SepseAppTests** no simulador.

Pela linha de comando:

```bash
xcodebuild test \
  -project SepseApp/SepseApp.xcodeproj \
  -scheme SepseApp \
  -destination 'platform=iOS Simulator,name=iPhone 15'
```

Cobertura dos testes (`SepseApp/SepseAppTests/`):
- `ScoreCalculatorsTests` — qSOFA, SOFA (componentes + sepse), SIRS (limiar 38,0), NEWS, APACHE II, MEDS.
- `ServicesTests` — ClassificationAdvisor, AlertService (NEWS, lactato, janela de antibiótico,
  alergia), AllergyChecker (conflito/cautela), DoseCalculator (30 mL/kg, vasopressor, função renal).
- `PatientCodableTests` — round-trip e decodificação resiliente (JSON legado sem campos novos).
- `ClinicalScenariosTests` — os 10 cenários clínicos obrigatórios.

## 6. Onde verificar logs

- **Console de runtime:** parte inferior do Xcode (**View ▸ Debug Area ▸ Activate Console**, ⌘⇧Y).
  Mensagens de falha de persistência aparecem aqui (`print` no `DataStore`).
- **Resultados de teste:** navegador **Report** (⌘9) → último *Test* → detalhamento por caso.
- **Erros de build:** navegador **Issue** (⌘5).

## 7. Testar no iPhone físico

1. Conecte o iPhone via USB e confie no computador.
2. Selecione o dispositivo no seletor de destino.
3. Target `SepseApp` ▸ **Signing & Capabilities** ▸ Team (Apple ID pessoal serve para teste).
4. **⌘R**. Na primeira vez, em **Ajustes ▸ Geral ▸ VPN e Gerenciamento de Dispositivos** do
   iPhone, confie no perfil de desenvolvedor.

## Observação de dados

Os dados de pacientes ficam em JSON no diretório de Documentos do app (offline). Apagar o app
remove os dados. A decodificação é resiliente: adicionar campos ao modelo não apaga pacientes
já gravados.
