import Foundation

/// Perfil completo de um paciente, incluindo dados demográficos, clínicos basais e
/// histórico longitudinal (medições de scores, eventos e itens de protocolo).
struct Patient: Identifiable, Codable, Equatable {
    var id: UUID = UUID()
    var criadoEm: Date = Date()
    var atualizadoEm: Date = Date()

    // MARK: Dados demográficos
    var nome: String = ""
    var idade: Int = 0
    var sexo: Sexo = .masculino
    var pesoKg: Double = 70
    var alturaCm: Double = 170

    // MARK: Dados clínicos basais
    var comorbidades: Set<Comorbidade> = []
    var usouAntibioticos30Dias: Bool = false
    var antibioticosRecentes: String = ""
    var colonizacaoMDR: Set<OrganismoMDR> = []
    var alergias: String = ""
    /// Classes de antimicrobianos às quais o paciente é alérgico (cross-check estruturado).
    var alergiasClasses: Set<ClasseAntibiotico> = []
    var localAquisicao: LocalAquisicao = .comunidade
    var creatininaSerica: Double? = nil          // mg/dL
    var clearanceEstimado: Double? = nil         // mL/min (Cockcroft-Gault)
    var bilirrubinas: Double? = nil              // mg/dL
    var transaminases: String = ""               // texto livre (TGO/TGP)
    var lactato: Double? = nil                   // mmol/L (último valor)

    // MARK: Localização atual
    var ambiente: AmbienteAtendimento = .prontoSocorro

    // MARK: Estado clínico / linha do tempo
    var classificacao: ClassificacaoClinica = .indeterminado
    var probabilidadeInfeccao: ProbabilidadeInfeccao = .naoAvaliada
    var medicoesScores: [ScoreMeasurement] = []
    var eventos: [TimelineEvent] = []
    var protocoloItens: [BundleItem] = []
    var reconhecimentoSepse: Date? = nil         // timestamp do reconhecimento de sepse

    // MARK: Computados

    var imc: Double? {
        guard alturaCm > 0 else { return nil }
        let m = alturaCm / 100
        return pesoKg / (m * m)
    }

    /// Clearance de creatinina estimado por Cockcroft-Gault, caso não informado manualmente.
    /// Usa creatinina sérica e dados demográficos. Retorna mL/min.
    var clearanceCalculado: Double? {
        if let manual = clearanceEstimado { return manual }
        guard let cr = creatininaSerica, cr > 0, idade > 0, pesoKg > 0 else { return nil }
        var cl = ((140.0 - Double(idade)) * pesoKg) / (72.0 * cr)
        if sexo == .feminino { cl *= 0.85 }
        return cl
    }

    /// Cor de gravidade usada na lista de pacientes. Prioriza a classificação clínica;
    /// se indeterminada, infere a partir do último score de triagem.
    var gravidade: GravidadeCor {
        if classificacao != .indeterminado { return classificacao.cor }
        if let ultimo = ultimaMedicao(de: ambiente.scoreTriagemRecomendado) {
            return ultimo.gravidade
        }
        return .cinza
    }

    func ultimaMedicao(de tipo: TipoScore) -> ScoreMeasurement? {
        medicoesScores
            .filter { $0.tipo == tipo }
            .max(by: { $0.data < $1.data })
    }

    func medicoes(de tipo: TipoScore) -> [ScoreMeasurement] {
        medicoesScores
            .filter { $0.tipo == tipo }
            .sorted(by: { $0.data < $1.data })
    }
}
