import Foundation

/// qSOFA — Quick Sequential Organ Failure Assessment (Sepsis-3, Seymour 2016).
/// Faixa: 0–3 pontos.
enum QSOFACalculator: ScoreCalculator {
    static let tipo: TipoScore = .qsofa

    struct Input {
        /// Glasgow < 15 indica alteração do estado mental.
        var glasgow: Int = 15
        var frequenciaRespiratoria: Int = 16   // irpm
        var pressaoSistolica: Int = 120        // mmHg
    }

    static func calcular(_ input: Input) -> ScoreResult {
        var componentes: [(String, Int)] = []

        let pMental = input.glasgow < 15 ? 1 : 0
        componentes.append(("Estado mental alterado (Glasgow < 15)", pMental))

        let pFR = input.frequenciaRespiratoria >= 22 ? 1 : 0
        componentes.append(("Frequência respiratória ≥ 22/min", pFR))

        let pPAS = input.pressaoSistolica <= 100 ? 1 : 0
        componentes.append(("Pressão arterial sistólica ≤ 100 mmHg", pPAS))

        let total = pMental + pFR + pPAS

        let interpretacao: String
        let gravidade: GravidadeCor
        if total >= 2 {
            interpretacao = "qSOFA ≥ 2: sinalizador de alto risco de mortalidade. Avaliar disfunção orgânica com SOFA. NÃO use o qSOFA isoladamente para triagem. " + AppText.avisoQSOFA
            gravidade = .vermelho
        } else {
            interpretacao = "qSOFA < 2: risco prognóstico menor. " + AppText.avisoQSOFA
            gravidade = total == 1 ? .amarelo : .verde
        }

        return ScoreResult(total: total, interpretacao: interpretacao, gravidade: gravidade, componentes: componentes)
    }
}
