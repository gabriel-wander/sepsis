import Foundation

/// Resultado calculado de um score, contendo a pontuação total, interpretação textual
/// e a cor de gravidade associada.
struct ScoreResult: Equatable {
    var total: Int
    var interpretacao: String
    var gravidade: GravidadeCor
    /// Detalhamento opcional da contribuição de cada componente (rótulo -> pontos).
    var componentes: [(String, Int)] = []

    static func == (lhs: ScoreResult, rhs: ScoreResult) -> Bool {
        lhs.total == rhs.total &&
        lhs.interpretacao == rhs.interpretacao &&
        lhs.gravidade == rhs.gravidade
    }
}

/// Medição persistida de um score em um instante de tempo, para histórico e gráficos.
struct ScoreMeasurement: Identifiable, Codable, Equatable {
    var id: UUID = UUID()
    var tipo: TipoScore
    var data: Date = Date()
    var total: Int
    var interpretacao: String
    var gravidadeRaw: String

    var gravidade: GravidadeCor {
        GravidadeCor(rawValue: gravidadeRaw) ?? .cinza
    }

    init(tipo: TipoScore, data: Date = Date(), resultado: ScoreResult) {
        self.tipo = tipo
        self.data = data
        self.total = resultado.total
        self.interpretacao = resultado.interpretacao
        self.gravidadeRaw = resultado.gravidade.rawValue
    }
}

/// Protocolo comum a todas as calculadoras de score.
protocol ScoreCalculator {
    associatedtype Input
    static var tipo: TipoScore { get }
    static func calcular(_ input: Input) -> ScoreResult
}
