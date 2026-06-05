import SwiftUI

/// Tela inicial: lista de pacientes cadastrados com indicadores visuais de gravidade.
struct PatientListView: View {
    @EnvironmentObject var store: DataStore
    @State private var mostrandoNovoPaciente = false

    var body: some View {
        NavigationStack {
            Group {
                if store.pacientes.isEmpty {
                    ContentUnavailableViewCompat(
                        titulo: "Nenhum paciente",
                        sistema: "person.crop.circle.badge.plus",
                        mensagem: "Toque em + para cadastrar um novo paciente.")
                } else {
                    List {
                        ForEach(store.pacientes) { paciente in
                            NavigationLink(value: paciente.id) {
                                PatientRow(paciente: paciente)
                            }
                        }
                        .onDelete { store.remover(at: $0) }
                    }
                }
            }
            .navigationTitle("Pacientes")
            .navigationDestination(for: UUID.self) { id in
                PatientDetailView(pacienteID: id)
            }
            .toolbar {
                ToolbarItem(placement: .primaryAction) {
                    Button {
                        mostrandoNovoPaciente = true
                    } label: {
                        Label("Adicionar paciente", systemImage: "plus")
                    }
                }
            }
            .sheet(isPresented: $mostrandoNovoPaciente) {
                NavigationStack {
                    PatientFormView(modo: .novo)
                }
                .environmentObject(store)
            }
        }
    }
}

/// Linha da lista de pacientes.
struct PatientRow: View {
    let paciente: Patient

    var body: some View {
        HStack(spacing: 12) {
            SeverityDot(gravidade: paciente.gravidade, diametro: 16)
            VStack(alignment: .leading, spacing: 2) {
                Text(paciente.nome.isEmpty ? "Sem identificação" : paciente.nome)
                    .font(.headline)
                HStack(spacing: 6) {
                    Text("\(paciente.idade) anos")
                    Text("·")
                    Text(paciente.ambiente.rawValue)
                    if paciente.classificacao != .indeterminado {
                        Text("·")
                        Text(paciente.classificacao.rawValue)
                            .foregroundColor(paciente.classificacao.cor.cor)
                    }
                }
                .font(.caption)
                .foregroundColor(.secondary)
            }
            Spacer()
        }
        .padding(.vertical, 2)
    }
}

/// Wrapper que usa ContentUnavailableView quando disponível (iOS 17+) com fallback.
struct ContentUnavailableViewCompat: View {
    let titulo: String
    let sistema: String
    let mensagem: String

    var body: some View {
        if #available(iOS 17.0, *) {
            ContentUnavailableView(titulo, systemImage: sistema, description: Text(mensagem))
        } else {
            VStack(spacing: 12) {
                Image(systemName: sistema).font(.system(size: 48)).foregroundColor(.secondary)
                Text(titulo).font(.title3.bold())
                Text(mensagem).font(.subheadline).foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
            }
            .padding()
        }
    }
}
