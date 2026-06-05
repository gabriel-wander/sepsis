import Foundation

/// Cross-check entre as alergias por classe do paciente e os antimicrobianos/regimes.
enum AllergyChecker {
    enum Nivel {
        case conflito   // alergia direta à classe do fármaco
        case cautela    // reatividade cruzada possível (penicilina ↔ cefalosporina/carbapenêmico)
    }

    struct Resultado: Equatable {
        let nivel: Nivel
        let mensagem: String
    }

    /// Avalia um antimicrobiano isolado contra as alergias por classe do paciente.
    static func avaliar(antimicrobiano: Antimicrobial, paciente: Patient) -> Resultado? {
        let alergias = paciente.alergiasClasses
        guard !alergias.isEmpty else { return nil }
        let classes = Set(antimicrobiano.classesAlergenicas)

        // Conflito direto: o fármaco pertence a uma classe a que o paciente é alérgico.
        if !classes.isDisjoint(with: alergias) {
            return Resultado(nivel: .conflito,
                             mensagem: "Alergia registrada à classe de \(antimicrobiano.nome). Evitar — selecionar alternativa.")
        }

        // Reatividade cruzada: alergia a penicilina/beta-lactâmico com cefalosporina ou carbapenêmico.
        if alergias.contains(.penicilina) || alergias.contains(.betalactamico) {
            if classes.contains(.cefalosporina) || classes.contains(.carbapenemico) {
                return Resultado(nivel: .cautela,
                                 mensagem: "Alergia a beta-lactâmico/penicilina: avaliar reatividade cruzada antes de usar \(antimicrobiano.nome).")
            }
        }
        return nil
    }

    /// Avalia um regime empírico (texto livre) detectando fármacos conhecidos do banco.
    /// Retorna o achado mais grave (conflito tem precedência sobre cautela).
    static func avaliar(regime: EmpiricRegimen, paciente: Patient) -> Resultado? {
        guard !paciente.alergiasClasses.isEmpty else { return nil }
        var cautela: Resultado?
        for atb in AntimicrobialDatabase.antimicrobianos
        where regime.regime.localizedCaseInsensitiveContains(atb.nome) {
            if let r = avaliar(antimicrobiano: atb, paciente: paciente) {
                if r.nivel == .conflito { return r }
                cautela = r
            }
        }
        return cautela
    }
}
