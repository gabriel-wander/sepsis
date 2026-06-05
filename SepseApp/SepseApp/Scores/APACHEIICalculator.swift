import Foundation

/// APACHE II — Acute Physiology and Chronic Health Evaluation II (Knaus 1985).
/// Faixa: 0–71 pontos = Acute Physiology Score (12 variáveis) + idade + saúde crônica.
enum APACHEIICalculator: ScoreCalculator {
    static let tipo: TipoScore = .apacheII

    enum CondicaoCronica: String, Codable, CaseIterable, Identifiable {
        case nenhuma = "Sem doença crônica grave"
        case naoOperatorioOuEmergencia = "Crônica grave — não-operatório / pós-op de emergência"
        case eletivoPosOp = "Crônica grave — pós-operatório eletivo"
        var id: String { rawValue }

        var pontos: Int {
            switch self {
            case .nenhuma: return 0
            case .naoOperatorioOuEmergencia: return 5
            case .eletivoPosOp: return 2
            }
        }
    }

    struct Input {
        var temperatura: Double = 37.0     // °C
        var pam: Double = 90               // mmHg
        var frequenciaCardiaca: Int = 80   // bpm
        var frequenciaRespiratoria: Int = 16
        var fio2: Double = 0.21            // fração (0–1)
        var pao2: Double = 95              // mmHg (usado se FiO₂ < 0,5)
        var aadO2: Double = 20             // mmHg (usado se FiO₂ ≥ 0,5)
        var ph: Double = 7.40
        var sodio: Double = 140            // mmol/L
        var potassio: Double = 4.2         // mmol/L
        var creatinina: Double = 1.0       // mg/dL
        var insuficienciaRenalAguda: Bool = false  // dobra a pontuação de creatinina
        var hematocrito: Double = 42       // %
        var leucocitos: Double = 9         // x10³/mm³
        var glasgow: Int = 15
        var idade: Int = 50
        var condicaoCronica: CondicaoCronica = .nenhuma
    }

    static func pTemp(_ v: Double) -> Int {
        if v >= 41 { return 4 }
        if v >= 39 { return 3 }
        if v >= 38.5 { return 1 }
        if v >= 36 { return 0 }
        if v >= 34 { return 1 }
        if v >= 32 { return 2 }
        if v >= 30 { return 3 }
        return 4
    }

    static func pPAM(_ v: Double) -> Int {
        if v >= 160 { return 4 }
        if v >= 130 { return 3 }
        if v >= 110 { return 2 }
        if v >= 70 { return 0 }
        if v >= 50 { return 2 }
        return 4
    }

    static func pFC(_ v: Int) -> Int {
        if v >= 180 { return 4 }
        if v >= 140 { return 3 }
        if v >= 110 { return 2 }
        if v >= 70 { return 0 }
        if v >= 55 { return 2 }
        if v >= 40 { return 3 }
        return 4
    }

    static func pFR(_ v: Int) -> Int {
        if v >= 50 { return 4 }
        if v >= 35 { return 3 }
        if v >= 25 { return 1 }
        if v >= 12 { return 0 }
        if v >= 10 { return 1 }
        if v >= 6 { return 2 }
        return 4
    }

    static func pOxigenacao(_ i: Input) -> Int {
        if i.fio2 >= 0.5 {
            // Usa gradiente alvéolo-arterial (A-aDO₂)
            if i.aadO2 >= 500 { return 4 }
            if i.aadO2 >= 350 { return 3 }
            if i.aadO2 >= 200 { return 2 }
            return 0
        } else {
            // Usa PaO₂
            if i.pao2 > 70 { return 0 }
            if i.pao2 >= 61 { return 1 }
            if i.pao2 >= 55 { return 3 }
            return 4
        }
    }

    static func pPH(_ v: Double) -> Int {
        if v >= 7.7 { return 4 }
        if v >= 7.6 { return 3 }
        if v >= 7.5 { return 1 }
        if v >= 7.33 { return 0 }
        if v >= 7.25 { return 2 }
        if v >= 7.15 { return 3 }
        return 4
    }

    static func pSodio(_ v: Double) -> Int {
        if v >= 180 { return 4 }
        if v >= 160 { return 3 }
        if v >= 155 { return 2 }
        if v >= 150 { return 1 }
        if v >= 130 { return 0 }
        if v >= 120 { return 2 }
        if v >= 111 { return 3 }
        return 4
    }

    static func pPotassio(_ v: Double) -> Int {
        if v >= 7 { return 4 }
        if v >= 6 { return 3 }
        if v >= 5.5 { return 1 }
        if v >= 3.5 { return 0 }
        if v >= 3 { return 1 }
        if v >= 2.5 { return 2 }
        return 4
    }

    static func pCreatinina(_ i: Input) -> Int {
        let base: Int
        if i.creatinina >= 3.5 { base = 4 }
        else if i.creatinina >= 2.0 { base = 3 }
        else if i.creatinina >= 1.5 { base = 2 }
        else if i.creatinina >= 0.6 { base = 0 }
        else { base = 2 }
        return i.insuficienciaRenalAguda ? base * 2 : base
    }

    static func pHematocrito(_ v: Double) -> Int {
        if v >= 60 { return 4 }
        if v >= 50 { return 2 }
        if v >= 46 { return 1 }
        if v >= 30 { return 0 }
        if v >= 20 { return 2 }
        return 4
    }

    static func pLeucocitos(_ v: Double) -> Int {
        if v >= 40 { return 4 }
        if v >= 20 { return 2 }
        if v >= 15 { return 1 }
        if v >= 3 { return 0 }
        if v >= 1 { return 2 }
        return 4
    }

    static func pIdade(_ v: Int) -> Int {
        if v >= 75 { return 6 }
        if v >= 65 { return 5 }
        if v >= 55 { return 3 }
        if v >= 45 { return 2 }
        return 0
    }

    static func calcular(_ input: Input) -> ScoreResult {
        let temp = pTemp(input.temperatura)
        let pam = pPAM(input.pam)
        let fc = pFC(input.frequenciaCardiaca)
        let fr = pFR(input.frequenciaRespiratoria)
        let oxi = pOxigenacao(input)
        let ph = pPH(input.ph)
        let na = pSodio(input.sodio)
        let k = pPotassio(input.potassio)
        let cr = pCreatinina(input)
        let ht = pHematocrito(input.hematocrito)
        let leuco = pLeucocitos(input.leucocitos)
        let gcs = max(0, 15 - input.glasgow)
        let idade = pIdade(input.idade)
        let cronica = input.condicaoCronica.pontos

        let aps = temp + pam + fc + fr + oxi + ph + na + k + cr + ht + leuco + gcs

        let componentes: [(String, Int)] = [
            ("Temperatura", temp),
            ("PAM", pam),
            ("Frequência cardíaca", fc),
            ("Frequência respiratória", fr),
            ("Oxigenação", oxi),
            ("pH arterial", ph),
            ("Sódio", na),
            ("Potássio", k),
            ("Creatinina", cr),
            ("Hematócrito", ht),
            ("Leucócitos", leuco),
            ("Glasgow (15 − GCS)", gcs),
            ("Pontos por idade", idade),
            ("Saúde crônica", cronica)
        ]

        let total = aps + idade + cronica

        let mortalidade: String
        let gravidade: GravidadeCor
        switch total {
        case ...4: mortalidade = "~4%"; gravidade = .verde
        case 5...9: mortalidade = "~8%"; gravidade = .verde
        case 10...14: mortalidade = "~15%"; gravidade = .amarelo
        case 15...19: mortalidade = "~25%"; gravidade = .amarelo
        case 20...24: mortalidade = "~40%"; gravidade = .vermelho
        case 25...29: mortalidade = "~55%"; gravidade = .vermelho
        case 30...34: mortalidade = "~75%"; gravidade = .vermelho
        default: mortalidade = "~85%"; gravidade = .vermelho
        }

        let interpretacao = "APACHE II \(total) (APS \(aps) + idade \(idade) + crônica \(cronica)). Mortalidade hospitalar estimada \(mortalidade)."

        return ScoreResult(total: total, interpretacao: interpretacao, gravidade: gravidade, componentes: componentes)
    }
}
