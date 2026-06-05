import Foundation

/// Item de um bundle (pacote de medidas) com estado de conclusão e timestamp.
struct BundleItem: Identifiable, Codable, Equatable {
    var id: UUID = UUID()
    var bundle: BundleTipo
    var titulo: String
    var concluido: Bool = false
    var concluidoEm: Date? = nil

    enum BundleTipo: String, Codable, CaseIterable, Identifiable {
        case umaHora = "Bundle de 1 hora"
        case tresHoras = "Bundle de 3 horas"
        case seisHoras = "Bundle de 6 horas"

        var id: String { rawValue }

        /// Prazo do bundle em segundos, a partir do reconhecimento de sepse.
        var prazoSegundos: TimeInterval {
            switch self {
            case .umaHora: return 3600
            case .tresHoras: return 3 * 3600
            case .seisHoras: return 6 * 3600
            }
        }
    }

    /// Conjunto padrão de itens de bundle (Surviving Sepsis Campaign 2021).
    static func padrao() -> [BundleItem] {
        [
            BundleItem(bundle: .umaHora, titulo: "Dosar lactato sérico"),
            BundleItem(bundle: .umaHora, titulo: "Coletar hemoculturas antes dos antibióticos"),
            BundleItem(bundle: .umaHora, titulo: "Antibiótico (≤1 h se choque/alta probabilidade; ≤3 h se possível sem choque)"),
            BundleItem(bundle: .umaHora, titulo: "Iniciar cristaloide 30 mL/kg (individualizar) se hipotensão ou lactato ≥4"),
            BundleItem(bundle: .tresHoras, titulo: "Completar ressuscitação volêmica (30 mL/kg)"),
            BundleItem(bundle: .tresHoras, titulo: "Reavaliar estado volêmico com medidas dinâmicas"),
            BundleItem(bundle: .seisHoras, titulo: "Repetir lactato se inicialmente elevado"),
            BundleItem(bundle: .seisHoras, titulo: "Iniciar vasopressor para PAM ≥65 mmHg se hipotensão persistente"),
            BundleItem(bundle: .seisHoras, titulo: "Reavaliar perfusão (enchimento capilar, débito urinário)")
        ]
    }
}

/// Passo de um fluxograma de protocolo, marcável como concluído na interface.
struct FluxogramaPasso: Identifiable {
    var id = UUID()
    var titulo: String
    var detalhe: String
}

/// Fluxograma de protocolo baseado nas diretrizes Surviving Sepsis Campaign 2021.
struct Fluxograma: Identifiable {
    var id = UUID()
    var numero: Int
    var titulo: String
    var passos: [FluxogramaPasso]
}
