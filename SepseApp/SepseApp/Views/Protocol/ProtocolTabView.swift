import SwiftUI

/// Aba de protocolo: timer desde o reconhecimento de sepse, checklist de bundles (1/3/6 h)
/// e fluxogramas interativos baseados na Surviving Sepsis Campaign 2021.
struct ProtocolTabView: View {
    @EnvironmentObject var store: DataStore
    let pacienteID: UUID

    private var paciente: Patient? { store.paciente(comID: pacienteID) }

    var body: some View {
        List {
            Section { DisclaimerBanner() }
            if let p = paciente {
                    AntibioticTimingSection(pacienteID: pacienteID, paciente: p)
                    SepsisTimerSection(pacienteID: pacienteID, reconhecimento: p.reconhecimentoSepse)
                    BundleSection(pacienteID: pacienteID, itens: p.protocoloItens, reconhecimento: p.reconhecimentoSepse)
                }

                Section("Fluxogramas — Surviving Sepsis Campaign 2021") {
                    ForEach(ProtocolData.fluxogramas) { fluxo in
                        NavigationLink {
                            FluxogramaDetailView(fluxograma: fluxo)
                        } label: {
                            HStack {
                                Text("\(fluxo.numero)")
                                    .font(.headline)
                                    .frame(width: 28, height: 28)
                                    .background(Color.accentColor.opacity(0.2))
                                    .clipShape(Circle())
                                Text(fluxo.titulo)
                            }
                        }
                    }
                }
            }
        .navigationBarTitleDisplayMode(.inline)
    }
}

// MARK: - Tempo de antibiótico por probabilidade e gravidade (SSC 2021)

struct AntibioticTimingSection: View {
    @EnvironmentObject var store: DataStore
    let pacienteID: UUID
    let paciente: Patient

    var body: some View {
        Section("Decisão de antibiótico") {
            Picker("Probabilidade de infecção/sepse", selection: Binding(
                get: { paciente.probabilidadeInfeccao },
                set: { nova in var p = paciente; p.probabilidadeInfeccao = nova; store.atualizar(p) })) {
                ForEach(ProbabilidadeInfeccao.allCases) { Text($0.rawValue).tag($0) }
            }

            let janela = AlertService.janelaAntibioticoSegundos(para: paciente)
            HStack(alignment: .top, spacing: 8) {
                Image(systemName: janela == nil ? "magnifyingglass" : "clock.badge.exclamationmark")
                    .foregroundColor(janela == nil ? .blue : (janela ?? 0) <= 3600 ? .red : .orange)
                Text(recomendacao(janela: janela, paciente: paciente))
                    .font(.caption)
                    .fixedSize(horizontal: false, vertical: true)
            }
        }
    }

    private func recomendacao(janela: TimeInterval?, paciente: Patient) -> String {
        if paciente.classificacao == .choqueSeptico {
            return "Choque séptico: antibiótico de amplo espectro IMEDIATO, idealmente ≤ 1 hora."
        }
        switch paciente.probabilidadeInfeccao {
        case .alta:
            return "Alta probabilidade: antibiótico idealmente ≤ 1 hora."
        case .possivel, .naoAvaliada:
            return "Possível sepse sem choque: investigação rápida e antibiótico ≤ 3 horas se a suspeita persistir."
        case .baixa:
            return "Baixa probabilidade sem choque: considerar observação/investigação e reavaliação. Não forçar antibiótico empírico."
        }
    }
}

// MARK: - Timer de reconhecimento

struct SepsisTimerSection: View {
    @EnvironmentObject var store: DataStore
    let pacienteID: UUID
    let reconhecimento: Date?

    var body: some View {
        Section("Reconhecimento de sepse") {
            if let inicio = reconhecimento {
                TimelineView(.periodic(from: .now, by: 1)) { context in
                    let decorrido = context.date.timeIntervalSince(inicio)
                    HStack {
                        Image(systemName: "timer").foregroundColor(.accentColor)
                            .accessibilityHidden(true)
                        VStack(alignment: .leading) {
                            Text("Tempo decorrido").font(.caption).foregroundColor(.secondary)
                            Text(formatado(decorrido))
                                .font(.system(size: 28, weight: .bold, design: .monospaced))
                                .foregroundColor(decorrido > AlertService.prazoAntibioticoSegundos ? .red : .primary)
                        }
                        Spacer()
                    }
                    // VoiceOver: granularidade de minutos para evitar leitura a cada segundo.
                    .accessibilityElement(children: .ignore)
                    .accessibilityLabel("Tempo decorrido desde o reconhecimento: \(Int(decorrido) / 3600) horas e \((Int(decorrido) % 3600) / 60) minutos")
                    Text("Meta de antibiótico: 1 hora").font(.caption).foregroundColor(.secondary)
                }
            } else {
                Button {
                    let ev = TimelineEvent(tipo: .reconhecimentoSepse, detalhe: "Início do protocolo")
                    store.registrarEvento(ev, paraPacienteID: pacienteID)
                } label: {
                    Label("Iniciar protocolo (marcar reconhecimento)", systemImage: "play.circle.fill")
                }
            }
        }
    }

    private func formatado(_ intervalo: TimeInterval) -> String {
        let total = Int(intervalo)
        let h = total / 3600
        let m = (total % 3600) / 60
        let s = total % 60
        return String(format: "%02d:%02d:%02d", h, m, s)
    }
}

// MARK: - Bundles

struct BundleSection: View {
    @EnvironmentObject var store: DataStore
    let pacienteID: UUID
    let itens: [BundleItem]
    let reconhecimento: Date?

    var body: some View {
        ForEach(BundleItem.BundleTipo.allCases) { bundle in
            let itensBundle = itens.filter { $0.bundle == bundle }
            if !itensBundle.isEmpty {
                Section(bundle.rawValue) {
                    ForEach(itensBundle) { item in
                        Button {
                            alternar(item)
                        } label: {
                            HStack {
                                Image(systemName: item.concluido ? "checkmark.circle.fill" : "circle")
                                    .foregroundColor(item.concluido ? .green : .secondary)
                                    .accessibilityHidden(true)
                                Text(item.titulo)
                                    .foregroundColor(.primary)
                                    .strikethrough(item.concluido)
                                Spacer()
                            }
                        }
                        .accessibilityElement(children: .combine)
                        .accessibilityValue(item.concluido ? "Concluído" : "Pendente")
                        .accessibilityHint("Toque para alternar")
                    }
                }
            }
        }
    }

    private func alternar(_ item: BundleItem) {
        guard var p = store.paciente(comID: pacienteID),
              let idx = p.protocoloItens.firstIndex(where: { $0.id == item.id }) else { return }
        p.protocoloItens[idx].concluido.toggle()
        p.protocoloItens[idx].concluidoEm = p.protocoloItens[idx].concluido ? Date() : nil
        store.atualizar(p)
    }
}

// MARK: - Detalhe do fluxograma

struct FluxogramaDetailView: View {
    let fluxograma: Fluxograma
    @State private var concluidos: Set<UUID> = []

    var body: some View {
        List {
            Section { DisclaimerBanner() }
            ForEach(Array(fluxograma.passos.enumerated()), id: \.element.id) { idx, passo in
                Section {
                    Button {
                        if concluidos.contains(passo.id) { concluidos.remove(passo.id) }
                        else { concluidos.insert(passo.id) }
                    } label: {
                        HStack(alignment: .top, spacing: 10) {
                            Image(systemName: concluidos.contains(passo.id) ? "checkmark.circle.fill" : "circle")
                                .foregroundColor(concluidos.contains(passo.id) ? .green : .accentColor)
                                .accessibilityHidden(true)
                            VStack(alignment: .leading, spacing: 4) {
                                Text("Passo \(idx + 1): \(passo.titulo)")
                                    .font(.headline).foregroundColor(.primary)
                                Text(passo.detalhe)
                                    .font(.subheadline).foregroundColor(.secondary)
                                    .fixedSize(horizontal: false, vertical: true)
                            }
                        }
                    }
                    .accessibilityElement(children: .combine)
                    .accessibilityValue(concluidos.contains(passo.id) ? "Concluído" : "Pendente")
                }
            }
        }
        .navigationTitle("Fluxograma \(fluxograma.numero)")
        .navigationBarTitleDisplayMode(.inline)
    }
}
