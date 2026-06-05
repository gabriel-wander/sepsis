import Foundation

// MARK: - Demografia

enum Sexo: String, Codable, CaseIterable, Identifiable {
    case masculino = "Masculino"
    case feminino = "Feminino"
    case outro = "Outro"

    var id: String { rawValue }
}

// MARK: - Ambiente de atendimento

/// Local físico onde o paciente está sendo atendido.
/// Determina qual score de triagem é mais apropriado (qSOFA fora da UTI, SOFA na UTI).
enum AmbienteAtendimento: String, Codable, CaseIterable, Identifiable {
    case preHospitalar = "Pré-hospitalar"
    case prontoSocorro = "Pronto-socorro"
    case enfermaria = "Enfermaria"
    case uti = "UTI"

    var id: String { rawValue }

    /// Indica se o paciente está em ambiente de terapia intensiva.
    var isUTI: Bool { self == .uti }

    /// Score de triagem recomendado para o ambiente.
    ///
    /// Importante (SSC 2021): qSOFA **não** deve ser usado como ferramenta única de triagem.
    /// Fora da UTI prioriza-se NEWS (deterioração clínica) + avaliação clínica; na UTI, SOFA.
    /// O qSOFA permanece disponível apenas como sinalizador de risco/prognóstico.
    var scoreTriagemRecomendado: TipoScore {
        isUTI ? .sofa : .news
    }
}

// MARK: - Probabilidade de infecção/sepse (avaliação clínica)

/// Avaliação clínica da probabilidade de infecção/sepse. Dirige a lógica de tempo de antibiótico
/// (SSC 2021), sem substituir o julgamento do médico.
enum ProbabilidadeInfeccao: String, Codable, CaseIterable, Identifiable {
    case alta = "Alta probabilidade"
    case possivel = "Possível (incerta)"
    case baixa = "Baixa probabilidade"
    case naoAvaliada = "Não avaliada"

    var id: String { rawValue }
}

// MARK: - Local de aquisição da infecção

enum LocalAquisicao: String, Codable, CaseIterable, Identifiable {
    case comunidade = "Comunidade"
    case hospitalar = "Hospitalar"
    case ilpi = "Instituição de longa permanência"

    var id: String { rawValue }
}

// MARK: - Comorbidades

enum Comorbidade: String, Codable, CaseIterable, Identifiable {
    case diabetes = "Diabetes"
    case insuficienciaRenal = "Insuficiência renal"
    case insuficienciaHepatica = "Insuficiência hepática"
    case insuficienciaCardiaca = "Insuficiência cardíaca"
    case dpoc = "DPOC"
    case imunossupressao = "Imunossupressão"
    case neoplasia = "Neoplasia"

    var id: String { rawValue }
}

// MARK: - Colonização por multirresistentes

enum OrganismoMDR: String, Codable, CaseIterable, Identifiable {
    case mrsa = "MRSA"
    case pseudomonasMDR = "Pseudomonas MDR"
    case enterobacteriaCarbapenemase = "Enterobactéria produtora de carbapenemase"

    var id: String { rawValue }
}

// MARK: - Classes de antimicrobianos (para cross-check de alergia)

enum ClasseAntibiotico: String, Codable, CaseIterable, Identifiable {
    case betalactamico = "Beta-lactâmicos (geral)"
    case penicilina = "Penicilinas"
    case cefalosporina = "Cefalosporinas"
    case carbapenemico = "Carbapenêmicos"
    case glicopeptideo = "Glicopeptídeos (vancomicina)"
    case fluoroquinolona = "Fluoroquinolonas"
    case macrolideo = "Macrolídeos"
    case sulfa = "Sulfas"
    case nitroimidazol = "Nitroimidazol (metronidazol)"

    var id: String { rawValue }
}

// MARK: - Classificação clínica (Sepsis-3)

enum ClassificacaoClinica: String, Codable, CaseIterable, Identifiable {
    case semSepse = "Infecção sem sepse"
    case sepse = "Sepse"
    case choqueSeptico = "Choque séptico"
    case indeterminado = "Indeterminado"

    var id: String { rawValue }

    var cor: GravidadeCor {
        switch self {
        case .semSepse: return .verde
        case .sepse: return .amarelo
        case .choqueSeptico: return .vermelho
        case .indeterminado: return .cinza
        }
    }
}

/// Indicador visual de gravidade usado na lista de pacientes e cabeçalhos.
enum GravidadeCor: String, Codable {
    case verde
    case amarelo
    case vermelho
    case cinza
}

// MARK: - Tipos de score

enum TipoScore: String, Codable, CaseIterable, Identifiable {
    case qsofa = "qSOFA"
    case sofa = "SOFA"
    case sirs = "SIRS"
    case news = "NEWS"
    case apacheII = "APACHE II"
    case meds = "MEDS"

    var id: String { rawValue }

    var nomeCompleto: String {
        switch self {
        case .qsofa: return "Quick Sequential Organ Failure Assessment"
        case .sofa: return "Sequential Organ Failure Assessment"
        case .sirs: return "Systemic Inflammatory Response Syndrome"
        case .news: return "National Early Warning Score"
        case .apacheII: return "Acute Physiology and Chronic Health Evaluation II"
        case .meds: return "Mortality in Emergency Department Sepsis"
        }
    }

    var quandoUsar: String {
        switch self {
        case .qsofa:
            return "Pacientes ≥18 anos em ambiente não-UTI (pré-hospitalar, enfermaria, pronto-socorro) com infecção confirmada ou suspeita."
        case .sofa:
            return "Pacientes em UTI com infecção confirmada ou suspeita. Critério diagnóstico para sepse (aumento ≥2 pontos do SOFA basal)."
        case .sirs:
            return "Triagem inicial de resposta inflamatória sistêmica (menos específico que qSOFA/SOFA)."
        case .news:
            return "Triagem de deterioração clínica em enfermarias."
        case .apacheII:
            return "Prognóstico de mortalidade em UTI."
        case .meds:
            return "Prognóstico de mortalidade em 28 dias no pronto-socorro."
        }
    }
}

// MARK: - Nível de consciência (AVPU) — usado no NEWS

enum NivelAVPU: String, Codable, CaseIterable, Identifiable {
    case alerta = "Alerta"
    case voz = "Resposta à voz"
    case dor = "Resposta à dor"
    case inconsciente = "Inconsciente"

    var id: String { rawValue }

    /// No NEWS, "Alerta" pontua 0; qualquer outro estado (V, P, U) pontua 3.
    var newsPontos: Int { self == .alerta ? 0 : 3 }
}
