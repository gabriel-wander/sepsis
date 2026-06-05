import Foundation

/// Entrada do banco de dados de antimicrobianos.
struct Antimicrobial: Identifiable, Codable, Equatable {
    var id: UUID = UUID()
    var nome: String
    var classe: String
    var espectro: String
    var doseUsual: String
    /// Orientação de ajuste por função renal (faixas de clearance).
    var ajusteRenal: String
    var contraindicacoes: String
    var interacoes: String
    /// Indica se a dose deve ser calculada por peso (mg/kg).
    var dosePorPeso: Bool = false
    var mgPorKg: Double? = nil
}

/// Regime empírico **editável** por foco/contexto da infecção.
///
/// Não há esquema universal: estes registros devem ser adaptados ao protocolo institucional/CCIH,
/// ao antibiograma local, às alergias, ao foco suspeito, à função renal/hepática e ao risco de
/// MRSA/MDR/fungo. Os exemplos pré-carregados vêm com `exemplo == true`.
struct EmpiricRegimen: Identifiable, Codable, Equatable {
    var id: UUID = UUID()
    var contexto: String
    var regime: String
    var observacao: String = ""
    /// Marca um registro como exemplo de fábrica (deve ser revisado/substituído pelo protocolo local).
    var exemplo: Bool = true
}
