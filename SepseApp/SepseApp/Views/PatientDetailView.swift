import SwiftUI

/// Tela do paciente com abas: Perfil, Scores, Protocolo, Medicações, Evolução.
struct PatientDetailView: View {
    @EnvironmentObject var store: DataStore
    let pacienteID: UUID

    /// Paciente vivo a partir do store (sempre atualizado).
    private var paciente: Patient? { store.paciente(comID: pacienteID) }

    var body: some View {
        if let paciente {
            TabView {
                ProfileTabView(paciente: paciente)
                    .tabItem { Label("Perfil", systemImage: "person.text.rectangle") }

                ScoresTabView(pacienteID: pacienteID)
                    .tabItem { Label("Scores", systemImage: "function") }

                ProtocolTabView(pacienteID: pacienteID)
                    .tabItem { Label("Protocolo", systemImage: "list.bullet.clipboard") }

                MedicationsTabView(pacienteID: pacienteID)
                    .tabItem { Label("Medicações", systemImage: "pills") }

                EvolutionTabView(pacienteID: pacienteID)
                    .tabItem { Label("Evolução", systemImage: "chart.xyaxis.line") }
            }
            .navigationTitle(paciente.nome.isEmpty ? "Paciente" : paciente.nome)
            .navigationBarTitleDisplayMode(.inline)
        } else {
            ContentUnavailableViewCompat(
                titulo: "Paciente não encontrado",
                sistema: "questionmark.folder",
                mensagem: "O registro pode ter sido removido.")
        }
    }
}

// MARK: - Aba Perfil

struct ProfileTabView: View {
    @EnvironmentObject var store: DataStore
    let paciente: Patient
    @State private var editando = false
    @State private var mostrandoShare = false
    @State private var pdfURL: URL?

    var body: some View {
        List {
            // Cabeçalho de gravidade + alertas
            Section {
                HStack {
                    SeverityDot(gravidade: paciente.gravidade, diametro: 20)
                    VStack(alignment: .leading) {
                        Text(paciente.classificacao.rawValue).font(.headline)
                        Text(paciente.gravidade.rotulo).font(.caption).foregroundColor(.secondary)
                    }
                    Spacer()
                }
                let alertas = AlertService.alertas(para: paciente)
                ForEach(alertas) { AlertCard(alerta: $0) }
            }

            Section {
                Picker("Classificação", selection: Binding(
                    get: { paciente.classificacao },
                    set: { nova in
                        var p = paciente; p.classificacao = nova; store.atualizar(p)
                    })) {
                    ForEach(ClassificacaoClinica.allCases) { Text($0.rawValue).tag($0) }
                }
                Picker("Probabilidade de infecção", selection: Binding(
                    get: { paciente.probabilidadeInfeccao },
                    set: { nova in
                        var p = paciente; p.probabilidadeInfeccao = nova; store.atualizar(p)
                    })) {
                    ForEach(ProbabilidadeInfeccao.allCases) { Text($0.rawValue).tag($0) }
                }
            } header: {
                Text("Classificação clínica")
            } footer: {
                Text("Sepse = infecção suspeita/confirmada + disfunção orgânica (SOFA ≥ 2 sobre o basal). Choque séptico = vasopressor para PAM ≥ 65 mmHg após ressuscitação volêmica adequada + lactato > 2 mmol/L. Confirmar com julgamento clínico.")
                    .font(.caption)
            }

            Section("Demografia") {
                LabeledContent("Idade", value: "\(paciente.idade) anos")
                LabeledContent("Sexo", value: paciente.sexo.rawValue)
                LabeledContent("Peso", value: String(format: "%.1f kg", paciente.pesoKg))
                LabeledContent("Altura", value: String(format: "%.0f cm", paciente.alturaCm))
                if let imc = paciente.imc {
                    LabeledContent("IMC", value: String(format: "%.1f kg/m²", imc))
                }
            }

            Section("Contexto da infecção") {
                LabeledContent("Ambiente", value: paciente.ambiente.rawValue)
                LabeledContent("Aquisição", value: paciente.localAquisicao.rawValue)
                if paciente.usouAntibioticos30Dias {
                    LabeledContent("ATB recente", value: paciente.antibioticosRecentes.isEmpty ? "Sim" : paciente.antibioticosRecentes)
                }
            }

            if !paciente.comorbidades.isEmpty {
                Section("Comorbidades") {
                    ForEach(paciente.comorbidades.sorted { $0.rawValue < $1.rawValue }) {
                        Text($0.rawValue)
                    }
                }
            }

            if !paciente.colonizacaoMDR.isEmpty {
                Section("Colonização MDR") {
                    ForEach(paciente.colonizacaoMDR.sorted { $0.rawValue < $1.rawValue }) {
                        Text($0.rawValue)
                    }
                }
            }

            if !paciente.alergias.trimmingCharacters(in: .whitespaces).isEmpty {
                Section("Alergias") { Text(paciente.alergias) }
            }

            Section("Laboratório basal") {
                if let cr = paciente.creatininaSerica {
                    LabeledContent("Creatinina", value: String(format: "%.2f mg/dL", cr))
                }
                if let cl = paciente.clearanceCalculado {
                    LabeledContent("Clearance", value: String(format: "%.0f mL/min", cl))
                }
                if let bb = paciente.bilirrubinas {
                    LabeledContent("Bilirrubinas", value: String(format: "%.1f mg/dL", bb))
                }
                if !paciente.transaminases.isEmpty {
                    LabeledContent("Transaminases", value: paciente.transaminases)
                }
            }
        }
        .toolbar {
            ToolbarItem(placement: .primaryAction) {
                Menu {
                    Button { editando = true } label: { Label("Editar", systemImage: "pencil") }
                    #if canImport(UIKit)
                    Button { exportarPDF() } label: { Label("Exportar PDF", systemImage: "square.and.arrow.up") }
                    #endif
                } label: { Image(systemName: "ellipsis.circle") }
            }
        }
        .sheet(isPresented: $editando) {
            NavigationStack { PatientFormView(modo: .editar(paciente)) }
                .environmentObject(store)
        }
        #if canImport(UIKit)
        .sheet(isPresented: $mostrandoShare) {
            if let pdfURL { ShareSheet(itens: [pdfURL]) }
        }
        #endif
    }

    #if canImport(UIKit)
    private func exportarPDF() {
        if let url = PDFExporter.gerarRelatorio(para: paciente) {
            pdfURL = url
            mostrandoShare = true
        }
    }
    #endif
}
