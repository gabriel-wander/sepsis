import SwiftUI

/// Aba de evolução: registro temporal de intervenções, linha do tempo e gráficos de scores.
struct EvolutionTabView: View {
    @EnvironmentObject var store: DataStore
    let pacienteID: UUID

    @State private var mostrandoNovoEvento = false

    private var paciente: Patient? { store.paciente(comID: pacienteID) }

    var body: some View {
        NavigationStack {
            List {
                if let p = paciente {
                    Section("Evolução dos scores") {
                        let tiposComDados = TipoScore.allCases.filter { !p.medicoes(de: $0).isEmpty }
                        if tiposComDados.isEmpty {
                            Text("Nenhum score registrado ainda.")
                                .font(.caption).foregroundColor(.secondary)
                        } else {
                            ForEach(tiposComDados) { tipo in
                                let medicoes = p.medicoes(de: tipo)
                                VStack(alignment: .leading, spacing: 6) {
                                    HStack {
                                        Text(tipo.rawValue).font(.subheadline.bold())
                                        Spacer()
                                        if let ultimo = medicoes.last {
                                            Text("Atual: \(ultimo.total)")
                                                .font(.caption)
                                                .foregroundColor(ultimo.gravidade.cor)
                                        }
                                    }
                                    ScoreLineChart(medicoes: medicoes, maximo: maximoEixo(tipo))
                                }
                                .padding(.vertical, 4)
                            }
                        }
                    }

                    Section("Linha do tempo") {
                        let eventos = p.eventos.sorted { $0.data > $1.data }
                        if eventos.isEmpty {
                            Text("Nenhuma intervenção registrada.")
                                .font(.caption).foregroundColor(.secondary)
                        } else {
                            ForEach(eventos) { ev in
                                HStack(alignment: .top, spacing: 10) {
                                    Image(systemName: ev.tipo.simbolo)
                                        .foregroundColor(.accentColor)
                                        .frame(width: 24)
                                        .accessibilityHidden(true)
                                    VStack(alignment: .leading, spacing: 2) {
                                        Text(ev.tipo.rawValue).font(.subheadline.bold())
                                        if !ev.detalhe.isEmpty {
                                            Text(ev.detalhe).font(.caption).foregroundColor(.secondary)
                                        }
                                        Text(ev.data, format: .dateTime.day().month().hour().minute())
                                            .font(.caption2).foregroundColor(.secondary)
                                    }
                                }
                                .accessibilityElement(children: .combine)
                            }
                        }
                    }
                }
            }
            .navigationTitle("Evolução")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .primaryAction) {
                    Button {
                        mostrandoNovoEvento = true
                    } label: {
                        Label("Registrar intervenção", systemImage: "plus")
                    }
                }
            }
            .sheet(isPresented: $mostrandoNovoEvento) {
                NavigationStack {
                    NewEventView(pacienteID: pacienteID)
                }
                .environmentObject(store)
            }
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

/// Formulário para registrar uma intervenção/evento com timestamp.
struct NewEventView: View {
    @EnvironmentObject var store: DataStore
    @Environment(\.dismiss) private var dismiss
    let pacienteID: UUID

    @State private var tipo: TimelineEvent.TipoEvento = .antibiotico
    @State private var detalhe: String = ""
    @State private var data: Date = Date()

    var body: some View {
        Form {
            Picker("Tipo de intervenção", selection: $tipo) {
                ForEach(TimelineEvent.TipoEvento.allCases) { Text($0.rawValue).tag($0) }
            }
            DatePicker("Data e hora", selection: $data)
            TextField("Detalhe (opcional)", text: $detalhe, axis: .vertical)
        }
        .navigationTitle("Nova intervenção")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .cancellationAction) {
                Button("Cancelar") { dismiss() }
            }
            ToolbarItem(placement: .confirmationAction) {
                Button("Salvar") {
                    let ev = TimelineEvent(tipo: tipo, data: data, detalhe: detalhe)
                    store.registrarEvento(ev, paraPacienteID: pacienteID)
                    dismiss()
                }
            }
        }
    }
}
