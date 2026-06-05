import Foundation

/// SOFA — Sequential Organ Failure Assessment (Vincent 1996; Sepsis-3).
/// Faixa: 0–24 pontos (6 sistemas × 0–4).
enum SOFACalculator: ScoreCalculator {
    static let tipo: TipoScore = .sofa

    struct Input {
        // Respiratório
        var pao2fio2: Double = 450          // mmHg (PaO₂/FiO₂)
        var suporteVentilatorio: Bool = false

        // Coagulação
        var plaquetas: Double = 250         // x10³/µL

        // Hepático
        var bilirrubina: Double = 0.8       // mg/dL

        // Cardiovascular
        var pam: Double = 80                // mmHg (pressão arterial média)
        var dopamina: Double = 0            // mcg/kg/min
        var dobutamina: Bool = false        // qualquer dose
        var epinefrina: Double = 0          // mcg/kg/min
        var norepinefrina: Double = 0       // mcg/kg/min

        // Neurológico
        var glasgow: Int = 15

        // Renal
        var creatinina: Double = 0.9        // mg/dL
        var debitoUrinario: Double? = nil   // mL/dia (opcional)

        /// SOFA basal do paciente (presumido 0 quando desconhecido), usado para o critério de sepse.
        var sofaBasal: Int = 0
    }

    static func respiratorio(_ i: Input) -> Int {
        if i.pao2fio2 < 100 && i.suporteVentilatorio { return 4 }
        if i.pao2fio2 < 200 && i.suporteVentilatorio { return 3 }
        if i.pao2fio2 < 300 { return 2 }
        if i.pao2fio2 < 400 { return 1 }
        return 0
    }

    static func coagulacao(_ i: Input) -> Int {
        if i.plaquetas < 20 { return 4 }
        if i.plaquetas < 50 { return 3 }
        if i.plaquetas < 100 { return 2 }
        if i.plaquetas < 150 { return 1 }
        return 0
    }

    static func hepatico(_ i: Input) -> Int {
        if i.bilirrubina >= 12.0 { return 4 }
        if i.bilirrubina >= 6.0 { return 3 }
        if i.bilirrubina >= 2.0 { return 2 }
        if i.bilirrubina >= 1.2 { return 1 }
        return 0
    }

    static func cardiovascular(_ i: Input) -> Int {
        // Doses de catecolaminas em mcg/kg/min.
        if i.dopamina > 15 || i.epinefrina > 0.1 || i.norepinefrina > 0.1 { return 4 }
        if i.dopamina > 5 || i.epinefrina > 0 || i.norepinefrina > 0 { return 3 }
        if i.dopamina > 0 || i.dobutamina { return 2 }
        if i.pam < 70 { return 1 }
        return 0
    }

    static func neurologico(_ i: Input) -> Int {
        if i.glasgow < 6 { return 4 }
        if i.glasgow <= 9 { return 3 }      // 6–9
        if i.glasgow <= 12 { return 2 }     // 10–12
        if i.glasgow <= 14 { return 1 }     // 13–14
        return 0                            // 15
    }

    static func renal(_ i: Input) -> Int {
        if let deb = i.debitoUrinario {
            if deb < 200 { return 4 }
            if deb < 500 { return 3 }
        }
        if i.creatinina >= 5.0 { return 4 }
        if i.creatinina >= 3.5 { return 3 }
        if i.creatinina >= 2.0 { return 2 }
        if i.creatinina >= 1.2 { return 1 }
        return 0
    }

    static func calcular(_ input: Input) -> ScoreResult {
        let resp = respiratorio(input)
        let coag = coagulacao(input)
        let hep = hepatico(input)
        let cv = cardiovascular(input)
        let neuro = neurologico(input)
        let ren = renal(input)

        let componentes: [(String, Int)] = [
            ("Respiratório (PaO₂/FiO₂)", resp),
            ("Coagulação (plaquetas)", coag),
            ("Hepático (bilirrubina)", hep),
            ("Cardiovascular (PAM/vasopressores)", cv),
            ("Neurológico (Glasgow)", neuro),
            ("Renal (creatinina/débito)", ren)
        ]

        let total = resp + coag + hep + cv + neuro + ren
        let delta = total - input.sofaBasal

        let interpretacao: String
        let gravidade: GravidadeCor
        if delta >= 2 {
            interpretacao = "SOFA \(total) (Δ +\(delta) sobre o basal \(input.sofaBasal)). Aumento ≥ 2 pontos + infecção = SEPSE. Mortalidade aumenta progressivamente com scores mais altos."
            gravidade = total >= 8 ? .vermelho : .amarelo
        } else {
            interpretacao = "SOFA \(total) (Δ +\(delta) sobre o basal \(input.sofaBasal)). Não atinge o critério de sepse (aumento ≥ 2). Manter monitorização."
            gravidade = total >= 2 ? .amarelo : .verde
        }

        return ScoreResult(total: total, interpretacao: interpretacao, gravidade: gravidade, componentes: componentes)
    }
}
