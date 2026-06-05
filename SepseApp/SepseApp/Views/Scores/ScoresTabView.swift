import SwiftUI

/// Aba de scores: seleção do score, entrada de dados com validação, resultado em tempo real
/// e registro do resultado no histórico do paciente.
struct ScoresTabView: View {
    @EnvironmentObject var store: DataStore
    let pacienteID: UUID

    @State private var tipoSelecionado: TipoScore = .qsofa

    private var paciente: Patient? { store.paciente(comID: pacienteID) }

    var body: some View {
        NavigationStack {
            Form {
                Section { DisclaimerBanner() }
                Section {
                    Picker("Score", selection: $tipoSelecionado) {
                        ForEach(TipoScore.allCases) { Text($0.rawValue).tag($0) }
                    }
                    .pickerStyle(.menu)
                } footer: {
                    VStack(alignment: .leading, spacing: 4) {
                        Text(tipoSelecionado.nomeCompleto).font(.caption.bold())
                        Text("Quando usar: \(tipoSelecionado.quandoUsar)").font(.caption)
                    }
                }

                if let recomendado = paciente?.ambiente.scoreTriagemRecomendado, recomendado == tipoSelecionado {
                    Section {
                        Label("Score de triagem recomendado para este ambiente.", systemImage: "checkmark.seal.fill")
                            .font(.caption).foregroundColor(.green)
                    }
                }

                if tipoSelecionado == .qsofa {
                    Section {
                        Label(AppText.avisoQSOFA, systemImage: "exclamationmark.triangle.fill")
                            .font(.caption).foregroundColor(.orange)
                    }
                }

                // Formulário específico do score
                switch tipoSelecionado {
                case .qsofa: QSOFAForm(pacienteID: pacienteID)
                case .sofa: SOFAForm(pacienteID: pacienteID)
                case .sirs: SIRSForm(pacienteID: pacienteID)
                case .news: NEWSForm(pacienteID: pacienteID)
                case .apacheII: APACHEIIForm(pacienteID: pacienteID)
                case .meds: MEDSForm(pacienteID: pacienteID)
                }

                if let p = paciente {
                    let historico = p.medicoes(de: tipoSelecionado)
                    if !historico.isEmpty {
                        Section("Histórico") {
                            ScoreLineChart(medicoes: historico, maximo: maximoEixo(tipoSelecionado))
                                .padding(.vertical, 4)
                            ForEach(historico.reversed()) { m in
                                HStack {
                                    SeverityDot(gravidade: m.gravidade)
                                    Text(m.data, format: .dateTime.day().month().hour().minute())
                                        .font(.caption)
                                    Spacer()
                                    Text("\(m.total)").font(.headline)
                                }
                            }
                        }
                    }
                }
            }
            .navigationTitle("Scores")
            .navigationBarTitleDisplayMode(.inline)
        }
    }

    private func maximoEixo(_ tipo: TipoScore) -> Int {
        switch tipo {
        case .qsofa: return 3
        case .sofa: return 24
        case .sirs: return 4
        case .news: return 20
        case .apacheII: return 71
        case .meds: return 24
        }
    }
}

/// Botão padrão para registrar uma medição de score no histórico.
struct RegistrarScoreButton: View {
    @EnvironmentObject var store: DataStore
    let pacienteID: UUID
    let tipo: TipoScore
    let resultado: ScoreResult

    var body: some View {
        Button {
            let medicao = ScoreMeasurement(tipo: tipo, resultado: resultado)
            store.registrarScore(medicao, paraPacienteID: pacienteID)
        } label: {
            Label("Registrar resultado no histórico", systemImage: "square.and.arrow.down")
                .frame(maxWidth: .infinity)
        }
        .buttonStyle(.borderedProminent)
    }
}
