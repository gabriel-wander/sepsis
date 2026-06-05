import Foundation

/// NEWS — National Early Warning Score (Royal College of Physicians).
/// Faixa: 0–20 pontos. Usado para triagem de deterioração clínica em enfermarias.
enum NEWSCalculator: ScoreCalculator {
    static let tipo: TipoScore = .news

    struct Input {
        var frequenciaRespiratoria: Int = 16   // irpm
        var spo2: Int = 98                      // %
        var oxigenioSuplementar: Bool = false
        var temperatura: Double = 37.0          // °C
        var pressaoSistolica: Int = 120         // mmHg
        var frequenciaCardiaca: Int = 75        // bpm
        var consciencia: NivelAVPU = .alerta
    }

    static func pontosFR(_ v: Int) -> Int {
        if v <= 8 { return 3 }
        if v <= 11 { return 1 }
        if v <= 20 { return 0 }
        if v <= 24 { return 2 }
        return 3
    }

    static func pontosSpO2(_ v: Int) -> Int {
        if v <= 91 { return 3 }
        if v <= 93 { return 2 }
        if v <= 95 { return 1 }
        return 0
    }

    static func pontosTemp(_ v: Double) -> Int {
        if v <= 35.0 { return 3 }
        if v <= 36.0 { return 1 }
        if v <= 38.0 { return 0 }
        if v <= 39.0 { return 1 }
        return 2
    }

    static func pontosPAS(_ v: Int) -> Int {
        if v <= 90 { return 3 }
        if v <= 100 { return 2 }
        if v <= 110 { return 1 }
        if v <= 219 { return 0 }
        return 3
    }

    static func pontosFC(_ v: Int) -> Int {
        if v <= 40 { return 3 }
        if v <= 50 { return 1 }
        if v <= 90 { return 0 }
        if v <= 110 { return 1 }
        if v <= 130 { return 2 }
        return 3
    }

    static func calcular(_ input: Input) -> ScoreResult {
        let fr = pontosFR(input.frequenciaRespiratoria)
        let spo2 = pontosSpO2(input.spo2)
        let o2 = input.oxigenioSuplementar ? 2 : 0
        let temp = pontosTemp(input.temperatura)
        let pas = pontosPAS(input.pressaoSistolica)
        let fc = pontosFC(input.frequenciaCardiaca)
        let consc = input.consciencia.newsPontos

        let componentes: [(String, Int)] = [
            ("Frequência respiratória", fr),
            ("Saturação de O₂", spo2),
            ("O₂ suplementar", o2),
            ("Temperatura", temp),
            ("Pressão sistólica", pas),
            ("Frequência cardíaca", fc),
            ("Nível de consciência (AVPU)", consc)
        ]

        let total = fr + spo2 + o2 + temp + pas + fc + consc

        let interpretacao: String
        let gravidade: GravidadeCor
        if total >= 7 {
            interpretacao = "NEWS ≥ 7: risco alto. Resposta de emergência e avaliação por equipe de cuidados intensivos."
            gravidade = .vermelho
        } else if total >= 5 {
            interpretacao = "NEWS 5–6: risco aumentado. Avaliação clínica urgente. Boa sensibilidade/especificidade para sepse."
            gravidade = .amarelo
        } else {
            interpretacao = "NEWS < 5: risco baixo a moderado. Manter monitorização de rotina."
            gravidade = total >= 3 ? .amarelo : .verde
        }

        return ScoreResult(total: total, interpretacao: interpretacao, gravidade: gravidade, componentes: componentes)
    }
}
