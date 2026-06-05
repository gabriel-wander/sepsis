import Foundation

/// Calculadoras de doses ponderadas e taxas de infusão para suporte à decisão clínica.
enum DoseCalculator {

    // MARK: - Ressuscitação volêmica

    /// Volume total de cristaloide recomendado na ressuscitação inicial (30 mL/kg).
    static func volumeRessuscitacaoMililitros(pesoKg: Double) -> Double {
        30.0 * pesoKg
    }

    // MARK: - Vasopressores

    /// Converte uma dose em mcg/kg/min para a taxa de infusão em mL/h.
    /// - Parameters:
    ///   - doseMcgKgMin: dose desejada em mcg/kg/min.
    ///   - pesoKg: peso do paciente em kg.
    ///   - concentracaoMcgPorMl: concentração da solução em mcg/mL.
    static func taxaInfusaoMlPorHora(doseMcgKgMin: Double, pesoKg: Double, concentracaoMcgPorMl: Double) -> Double {
        guard concentracaoMcgPorMl > 0 else { return 0 }
        let mcgPorMin = doseMcgKgMin * pesoKg
        let mcgPorHora = mcgPorMin * 60.0
        return mcgPorHora / concentracaoMcgPorMl
    }

    /// Converte uma dose em mcg/kg/min para mcg/min (dose absoluta).
    static func doseAbsolutaMcgMin(doseMcgKgMin: Double, pesoKg: Double) -> Double {
        doseMcgKgMin * pesoKg
    }

    // MARK: - Dose ponderada de antibióticos

    /// Calcula a dose total (mg) de um antimicrobiano dosado por peso.
    static func doseAntibioticoMg(mgPorKg: Double, pesoKg: Double) -> Double {
        mgPorKg * pesoKg
    }

    // MARK: - Ajuste por função renal

    enum FaixaRenal: String {
        case normal = "ClCr ≥ 50 mL/min — dose padrão"
        case moderada = "ClCr 30–49 mL/min — considerar ajuste"
        case grave = "ClCr 10–29 mL/min — ajuste obrigatório"
        case terminal = "ClCr < 10 mL/min — ajuste/diálise"
    }

    static func faixaRenal(clearance: Double) -> FaixaRenal {
        if clearance >= 50 { return .normal }
        if clearance >= 30 { return .moderada }
        if clearance >= 10 { return .grave }
        return .terminal
    }
}
