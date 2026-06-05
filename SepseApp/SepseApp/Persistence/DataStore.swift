import Foundation
import Combine

/// Armazenamento local dos pacientes, com persistência em JSON no diretório de Documentos.
///
/// Funciona totalmente offline. Os dados são serializados de forma atômica a cada alteração.
/// A serialização para JSON local mantém compatibilidade com a posterior migração para Core Data
/// ou sincronização em nuvem (CloudKit), conforme os requisitos do projeto.
final class DataStore: ObservableObject {
    @Published private(set) var pacientes: [Patient] = []
    /// Regimes antimicrobianos empíricos editáveis (protocolo institucional/CCIH).
    @Published private(set) var regimes: [EmpiricRegimen] = []

    private let arquivoURL: URL
    private let regimesURL: URL
    private let encoder: JSONEncoder
    private let decoder: JSONDecoder

    init(nomeArquivo: String = "pacientes.json") {
        let dir = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        self.arquivoURL = dir.appendingPathComponent(nomeArquivo)
        self.regimesURL = dir.appendingPathComponent("regimes.json")

        self.encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .iso8601
        encoder.outputFormatting = [.prettyPrinted, .sortedKeys]

        self.decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601

        carregar()
        carregarRegimes()
    }

    // MARK: - CRUD

    func adicionar(_ paciente: Patient) {
        var p = paciente
        p.atualizadoEm = Date()
        pacientes.insert(p, at: 0)
        salvar()
    }

    func atualizar(_ paciente: Patient) {
        guard let idx = pacientes.firstIndex(where: { $0.id == paciente.id }) else { return }
        var p = paciente
        p.atualizadoEm = Date()
        pacientes[idx] = p
        salvar()
    }

    func remover(_ paciente: Patient) {
        pacientes.removeAll { $0.id == paciente.id }
        salvar()
    }

    func remover(at offsets: IndexSet) {
        pacientes.remove(atOffsets: offsets)
        salvar()
    }

    func paciente(comID id: UUID) -> Patient? {
        pacientes.first { $0.id == id }
    }

    /// Acrescenta uma medição de score ao paciente e persiste.
    func registrarScore(_ medicao: ScoreMeasurement, paraPacienteID id: UUID) {
        guard var p = paciente(comID: id) else { return }
        p.medicoesScores.append(medicao)
        atualizar(p)
    }

    /// Registra um evento na linha do tempo do paciente.
    func registrarEvento(_ evento: TimelineEvent, paraPacienteID id: UUID) {
        guard var p = paciente(comID: id) else { return }
        p.eventos.append(evento)
        if evento.tipo == .reconhecimentoSepse && p.reconhecimentoSepse == nil {
            p.reconhecimentoSepse = evento.data
            if p.protocoloItens.isEmpty {
                p.protocoloItens = BundleItem.padrao()
            }
        }
        atualizar(p)
    }

    // MARK: - Regimes antimicrobianos (editáveis)

    func adicionarRegime(_ regime: EmpiricRegimen) {
        regimes.append(regime)
        salvarRegimes()
    }

    func atualizarRegime(_ regime: EmpiricRegimen) {
        guard let idx = regimes.firstIndex(where: { $0.id == regime.id }) else { return }
        regimes[idx] = regime
        salvarRegimes()
    }

    func removerRegimes(at offsets: IndexSet) {
        regimes.remove(atOffsets: offsets)
        salvarRegimes()
    }

    /// Restaura os exemplos de fábrica (substitui a lista atual).
    func restaurarRegimesPadrao() {
        regimes = AntimicrobialDatabase.defaultRegimes()
        salvarRegimes()
    }

    private func carregarRegimes() {
        guard FileManager.default.fileExists(atPath: regimesURL.path) else {
            regimes = AntimicrobialDatabase.defaultRegimes()
            salvarRegimes()
            return
        }
        do {
            let dados = try Data(contentsOf: regimesURL)
            regimes = try decoder.decode([EmpiricRegimen].self, from: dados)
        } catch {
            print("Falha ao carregar regimes: \(error)")
            regimes = AntimicrobialDatabase.defaultRegimes()
        }
    }

    private func salvarRegimes() {
        do {
            let dados = try encoder.encode(regimes)
            try dados.write(to: regimesURL, options: [.atomic])
        } catch {
            print("Falha ao salvar regimes: \(error)")
        }
    }

    // MARK: - Persistência

    private func carregar() {
        guard FileManager.default.fileExists(atPath: arquivoURL.path) else { return }
        do {
            let dados = try Data(contentsOf: arquivoURL)
            pacientes = try decoder.decode([Patient].self, from: dados)
        } catch {
            print("Falha ao carregar pacientes: \(error)")
        }
    }

    private func salvar() {
        do {
            let dados = try encoder.encode(pacientes)
            try dados.write(to: arquivoURL, options: [.atomic])
        } catch {
            print("Falha ao salvar pacientes: \(error)")
        }
    }
}
