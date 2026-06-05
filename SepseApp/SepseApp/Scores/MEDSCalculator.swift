import Foundation

/// MEDS — Mortality in Emergency Department Sepsis.
/// Prognóstico de mortalidade em 28 dias no pronto-socorro.
///
/// Implementação baseada nas variáveis listadas no protocolo clínico do app.
/// As variáveis de maior peso (idade, taquipneia, choque, plaquetas, bandas) recebem 3 pontos;
/// as demais, 2–3 pontos, alinhadas à literatura de Shapiro et al.
enum MEDSCalculator: ScoreCalculator {
    static let tipo: TipoScore = .meds

    struct Input {
        var idadeMaior65: Bool = false
        var bandasMaior5: Bool = false
        var taquipneia: Bool = false           // FR > 20/min ou hipoxemia
        var choqueSeptico: Bool = false
        var plaquetasBaixas: Bool = false      // < 150.000/µL
        var alteracaoEstadoMental: Bool = false
        var infeccaoHospitalar: Bool = false
        var residenciaILPI: Bool = false
        var lactatoElevado: Bool = false       // > 2,5 mmol/L
    }

    static func calcular(_ input: Input) -> ScoreResult {
        var componentes: [(String, Int)] = []
        func add(_ titulo: String, _ presente: Bool, _ pontos: Int) -> Int {
            let p = presente ? pontos : 0
            componentes.append((titulo, p))
            return p
        }

        var total = 0
        total += add("Idade > 65 anos", input.idadeMaior65, 3)
        total += add("Bandas > 5%", input.bandasMaior5, 3)
        total += add("Taquipneia / hipoxemia", input.taquipneia, 3)
        total += add("Choque séptico", input.choqueSeptico, 3)
        total += add("Plaquetas < 150.000/µL", input.plaquetasBaixas, 3)
        total += add("Lactato > 2,5 mmol/L", input.lactatoElevado, 3)
        total += add("Alteração do estado mental", input.alteracaoEstadoMental, 2)
        total += add("Infecção de origem hospitalar", input.infeccaoHospitalar, 2)
        total += add("Residência em ILPI", input.residenciaILPI, 2)

        let interpretacao: String
        let gravidade: GravidadeCor
        switch total {
        case ...4:
            interpretacao = "MEDS \(total) — risco muito baixo (mortalidade em 28 dias ~1%)."
            gravidade = .verde
        case 5...7:
            interpretacao = "MEDS \(total) — risco baixo (mortalidade em 28 dias ~4%)."
            gravidade = .amarelo
        case 8...12:
            interpretacao = "MEDS \(total) — risco moderado (mortalidade em 28 dias ~9%)."
            gravidade = .amarelo
        case 13...15:
            interpretacao = "MEDS \(total) — risco alto (mortalidade em 28 dias ~16%)."
            gravidade = .vermelho
        default:
            interpretacao = "MEDS \(total) — risco muito alto (mortalidade em 28 dias ~40%)."
            gravidade = .vermelho
        }

        return ScoreResult(total: total, interpretacao: interpretacao, gravidade: gravidade, componentes: componentes)
    }
}
