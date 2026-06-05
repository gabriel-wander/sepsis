import SwiftUI

/// Aba de medicações: regimes empíricos **editáveis** (protocolo institucional/CCIH),
/// banco de antimicrobianos (referência) e calculadoras de dose.
struct MedicationsTabView: View {
    @EnvironmentObject var store: DataStore
    let pacienteID: UUID

    @State private var editandoRegime: EmpiricRegimen?
    @State private var criandoRegime = false

    private var paciente: Patient? { store.paciente(comID: pacienteID) }

    var body: some View {
        NavigationStack {
            List {
                Section { DisclaimerBanner() }

                Section {
                    Label(AppText.fatoresAntimicrobiano, systemImage: "info.circle")
                        .font(.caption)
                } header: {
                    Text("Escolha do antimicrobiano")
                }

                Section {
                    if store.regimes.isEmpty {
                        Text("Nenhum regime cadastrado. Adicione conforme o protocolo institucional.")
                            .font(.caption).foregroundColor(.secondary)
                    } else {
                        ForEach(store.regimes) { reg in
                            Button { editandoRegime = reg } label: {
                                RegimeRow(regime: reg, destaque: relevante(reg))
                            }
                        }
                        .onDelete { store.removerRegimes(at: $0) }
                    }
                } header: {
                    Text("Regimes empíricos (institucionais — editáveis)")
                } footer: {
                    Text("Exemplos pré-carregados são apenas ponto de partida e devem ser substituídos pelo protocolo local/CCIH e antibiograma.")
                }

                Section {
                    Button { criandoRegime = true } label: {
                        Label("Adicionar regime", systemImage: "plus")
                    }
                    Button(role: .destructive) { store.restaurarRegimesPadrao() } label: {
                        Label("Restaurar exemplos de fábrica", systemImage: "arrow.counterclockwise")
                    }
                }

                if let p = paciente {
                    Section("Calculadoras de dose") {
                        NavigationLink {
                            DoseCalculatorView(paciente: p)
                        } label: {
                            Label("Fluidos, vasopressores e ATB por peso", systemImage: "function")
                        }
                    }
                }

                Section("Banco de antimicrobianos (referência)") {
                    ForEach(AntimicrobialDatabase.antimicrobianos) { atb in
                        NavigationLink {
                            AntimicrobialDetailView(antimicrobiano: atb, paciente: paciente)
                        } label: {
                            VStack(alignment: .leading) {
                                Text(atb.nome).font(.headline)
                                Text(atb.classe).font(.caption).foregroundColor(.secondary)
                            }
                        }
                    }
                }
            }
            .navigationTitle("Medicações")
            .navigationBarTitleDisplayMode(.inline)
            .sheet(item: $editandoRegime) { reg in
                NavigationStack { RegimeEditorView(modo: .editar(reg)) }
                    .environmentObject(store)
            }
            .sheet(isPresented: $criandoRegime) {
                NavigationStack { RegimeEditorView(modo: .novo) }
                    .environmentObject(store)
            }
        }
    }

    private func relevante(_ reg: EmpiricRegimen) -> Bool {
        guard let p = paciente else { return false }
        let contextos = AntimicrobialDatabase.contextosRelevantes(para: p)
        return contextos.contains { reg.contexto.localizedCaseInsensitiveContains($0) }
    }
}

struct RegimeRow: View {
    let regime: EmpiricRegimen
    let destaque: Bool

    var body: some View {
        VStack(alignment: .leading, spacing: 3) {
            HStack {
                Text(regime.contexto).font(.subheadline.bold()).foregroundColor(.primary)
                if destaque {
                    Text("relevante").font(.caption2).padding(.horizontal, 6).padding(.vertical, 2)
                        .background(Color.accentColor.opacity(0.2)).clipShape(Capsule())
                }
                if regime.exemplo {
                    Text("exemplo").font(.caption2).padding(.horizontal, 6).padding(.vertical, 2)
                        .background(Color.orange.opacity(0.2)).clipShape(Capsule())
                }
            }
            Text(regime.regime).font(.caption).foregroundColor(.secondary)
            if !regime.observacao.isEmpty {
                Text(regime.observacao).font(.caption2).foregroundColor(.secondary)
            }
        }
        .padding(.vertical, 2)
    }
}

/// Editor de regime antimicrobiano (criar/editar).
struct RegimeEditorView: View {
    enum Modo: Equatable { case novo; case editar(EmpiricRegimen) }

    @EnvironmentObject var store: DataStore
    @Environment(\.dismiss) private var dismiss

    let modo: Modo
    @State private var regime: EmpiricRegimen

    init(modo: Modo) {
        self.modo = modo
        switch modo {
        case .novo: _regime = State(initialValue: EmpiricRegimen(contexto: "", regime: "", exemplo: false))
        case .editar(let r): _regime = State(initialValue: r)
        }
    }

    var body: some View {
        Form {
            Section("Contexto / foco") {
                TextField("Ex.: Pneumonia comunitária", text: $regime.contexto)
            }
            Section("Esquema") {
                TextField("Antimicrobianos, doses e intervalos", text: $regime.regime, axis: .vertical)
            }
            Section("Observação") {
                TextField("Notas locais (CCIH, antibiograma, ajustes)", text: $regime.observacao, axis: .vertical)
            }
            Section {
                Toggle("Marcado como exemplo de fábrica", isOn: $regime.exemplo)
            } footer: {
                Text(AppText.fatoresAntimicrobiano)
            }
        }
        .navigationTitle(isNovo ? "Novo regime" : "Editar regime")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .cancellationAction) { Button("Cancelar") { dismiss() } }
            ToolbarItem(placement: .confirmationAction) {
                Button("Salvar") {
                    if isNovo { store.adicionarRegime(regime) } else { store.atualizarRegime(regime) }
                    dismiss()
                }
                .disabled(regime.contexto.trimmingCharacters(in: .whitespaces).isEmpty
                          || regime.regime.trimmingCharacters(in: .whitespaces).isEmpty)
            }
        }
    }

    private var isNovo: Bool { if case .novo = modo { return true }; return false }
}

// MARK: - Detalhe de antimicrobiano

struct AntimicrobialDetailView: View {
    let antimicrobiano: Antimicrobial
    let paciente: Patient?

    var body: some View {
        List {
            Section { DisclaimerBanner() }
            Section("Espectro") { Text(antimicrobiano.espectro) }
            Section("Dose usual") {
                Text(antimicrobiano.doseUsual)
                if antimicrobiano.dosePorPeso, let mgkg = antimicrobiano.mgPorKg, let p = paciente {
                    let dose = DoseCalculator.doseAntibioticoMg(mgPorKg: mgkg, pesoKg: p.pesoKg)
                    LabeledContent("Dose para \(Int(p.pesoKg)) kg", value: String(format: "%.0f mg", dose))
                }
            }
            Section("Ajuste por função renal") {
                Text(antimicrobiano.ajusteRenal)
                if let p = paciente, let cl = p.clearanceCalculado {
                    let faixa = DoseCalculator.faixaRenal(clearance: cl)
                    LabeledContent("ClCr do paciente", value: String(format: "%.0f mL/min", cl))
                    Text(faixa.rawValue).font(.caption).foregroundColor(.orange)
                }
            }
            Section("Contraindicações") { Text(antimicrobiano.contraindicacoes) }
            Section("Interações") { Text(antimicrobiano.interacoes) }
        }
        .navigationTitle(antimicrobiano.nome)
        .navigationBarTitleDisplayMode(.inline)
    }
}

// MARK: - Calculadoras de dose

struct DoseCalculatorView: View {
    let paciente: Patient

    @State private var doseVasopressor: Double = 0.1
    @State private var concentracao: Double = 16    // mcg/mL (ex.: norepinefrina 16 mg/250 mL)

    /// Comorbidades que exigem cautela com volume.
    private var riscoCongestao: [String] {
        var r: [String] = []
        if paciente.comorbidades.contains(.insuficienciaCardiaca) { r.append("insuficiência cardíaca") }
        if paciente.comorbidades.contains(.insuficienciaRenal) { r.append("DRC") }
        if paciente.comorbidades.contains(.insuficienciaHepatica) { r.append("cirrose/hepatopatia") }
        if paciente.idade >= 75 { r.append("idade avançada") }
        return r
    }

    var body: some View {
        Form {
            Section { DisclaimerBanner() }

            Section {
                let volume = DoseCalculator.volumeRessuscitacaoMililitros(pesoKg: paciente.pesoKg)
                LabeledContent("Peso", value: String(format: "%.1f kg", paciente.pesoKg))
                LabeledContent("Referência inicial (30 mL/kg)", value: String(format: "%.0f mL", volume))
                    .font(.headline)
                Text(AppText.avisoFluidos).font(.caption).foregroundColor(.secondary)
                if !riscoCongestao.isEmpty {
                    Label("Cautela com volume: \(riscoCongestao.joined(separator: ", ")). Reavaliar continuamente.",
                          systemImage: "exclamationmark.triangle.fill")
                        .font(.caption).foregroundColor(.orange)
                }
            } header: {
                Text("Ressuscitação volêmica (individualizável)")
            }

            Section("Vasopressor — norepinefrina (1ª linha)") {
                LabeledNumberField(titulo: "Dose (mcg/kg/min)", valor: $doseVasopressor)
                LabeledNumberField(titulo: "Concentração (mcg/mL)", valor: $concentracao)
                let taxa = DoseCalculator.taxaInfusaoMlPorHora(
                    doseMcgKgMin: doseVasopressor, pesoKg: paciente.pesoKg, concentracaoMcgPorMl: concentracao)
                let absoluta = DoseCalculator.doseAbsolutaMcgMin(doseMcgKgMin: doseVasopressor, pesoKg: paciente.pesoKg)
                LabeledContent("Dose absoluta", value: String(format: "%.1f mcg/min", absoluta))
                LabeledContent("Taxa de infusão", value: String(format: "%.1f mL/h", taxa))
                    .font(.headline)
                Text("Alvo inicial de PAM 65 mmHg. Vasopressina/epinefrina como adjuvantes; dobutamina apenas em disfunção miocárdica com PAM já adequada. Confirmar diluição com o protocolo local.")
                    .font(.caption).foregroundColor(.secondary)
            }

            Section("Função renal") {
                if let cl = paciente.clearanceCalculado {
                    LabeledContent("ClCr estimado", value: String(format: "%.0f mL/min", cl))
                    Text(DoseCalculator.faixaRenal(clearance: cl).rawValue)
                        .font(.caption).foregroundColor(.orange)
                } else {
                    Text("Informe creatinina/peso no perfil para estimar o clearance.")
                        .font(.caption).foregroundColor(.secondary)
                }
            }
        }
        .navigationTitle("Calculadoras")
        .navigationBarTitleDisplayMode(.inline)
    }
}
