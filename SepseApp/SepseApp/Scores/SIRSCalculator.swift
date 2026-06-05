import Foundation

/// SIRS — Systemic Inflammatory Response Syndrome.
/// Faixa: 0–4 critérios. ≥2 = SIRS presente.
enum SIRSCalculator: ScoreCalculator {
    static let tipo: TipoScore = .sirs

    struct Input {
        var temperatura: Double = 37.0     // °C
        var frequenciaCardiaca: Int = 80   // bpm
        var frequenciaRespiratoria: Int = 16
        var paco2: Double? = nil           // mmHg (opcional)
        var leucocitos: Double = 8000      // /mm³
        var bastoes: Double = 0            // % de bastões
    }

    static func calcular(_ input: Input) -> ScoreResult {
        var componentes: [(String, Int)] = []

        let pTemp = (input.temperatura > 38.5 || input.temperatura < 36.0) ? 1 : 0
        componentes.append(("Temperatura > 38,5 °C ou < 36 °C", pTemp))

        let pFC = input.frequenciaCardiaca > 90 ? 1 : 0
        componentes.append(("Frequência cardíaca > 90 bpm", pFC))

        let respAlterada = input.frequenciaRespiratoria > 20 || ((input.paco2 ?? 99) < 32)
        let pResp = respAlterada ? 1 : 0
        componentes.append(("FR > 20/min ou PaCO₂ < 32 mmHg", pResp))

        let leucoAlterado = input.leucocitos > 12000 || input.leucocitos < 4000 || input.bastoes > 10
        let pLeuco = leucoAlterado ? 1 : 0
        componentes.append(("Leucócitos > 12.000, < 4.000 ou > 10% bastões", pLeuco))

        let total = pTemp + pFC + pResp + pLeuco

        let interpretacao: String
        let gravidade: GravidadeCor
        if total >= 2 {
            interpretacao = "≥ 2 critérios = SIRS presente. SIRS + infecção = sepse (definição antiga, menos específica que qSOFA/SOFA)."
            gravidade = .amarelo
        } else {
            interpretacao = "< 2 critérios: SIRS ausente pela definição clássica."
            gravidade = .verde
        }

        return ScoreResult(total: total, interpretacao: interpretacao, gravidade: gravidade, componentes: componentes)
    }
}
