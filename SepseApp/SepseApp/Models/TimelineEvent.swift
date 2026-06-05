import Foundation

/// Registro temporal de uma intervenção ou marco relevante na evolução do paciente.
struct TimelineEvent: Identifiable, Codable, Equatable {
    var id: UUID = UUID()
    var tipo: TipoEvento
    var data: Date = Date()
    var detalhe: String = ""

    enum TipoEvento: String, Codable, CaseIterable, Identifiable {
        case reconhecimentoSepse = "Reconhecimento de sepse"
        case lactato = "Coleta de lactato"
        case hemoculturas = "Hemoculturas"
        case antibiotico = "Administração de antibiótico"
        case fluidos = "Ressuscitação volêmica"
        case vasopressor = "Início de vasopressor"
        case corticoide = "Corticosteroide"
        case controleFonte = "Controle de foco"
        case outro = "Outro"

        var id: String { rawValue }

        var simbolo: String {
            switch self {
            case .reconhecimentoSepse: return "exclamationmark.triangle.fill"
            case .lactato: return "drop.fill"
            case .hemoculturas: return "testtube.2"
            case .antibiotico: return "pills.fill"
            case .fluidos: return "ivfluid.bag.fill"
            case .vasopressor: return "bolt.heart.fill"
            case .corticoide: return "cross.case.fill"
            case .controleFonte: return "scissors"
            case .outro: return "note.text"
            }
        }
    }
}
