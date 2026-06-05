import Foundation

/// Sugestão (não vinculante) de classificação clínica a partir dos dados registrados.
///
/// **Apoio à decisão**: nunca altera a classificação automaticamente — apenas sinaliza ao médico
/// quando os dados são compatíveis com sepse ou choque séptico (Sepsis-3).
enum ClassificationAdvisor {

    static func sugestao(para paciente: Patient) -> String? {
        let vasopressorIniciado = paciente.eventos.contains { $0.tipo == .vasopressor }
        let lactatoElevado = (paciente.lactato ?? 0) > 2

        // Choque séptico = vasopressor (após volume) + lactato > 2 mmol/L.
        if vasopressorIniciado && lactatoElevado {
            return "Dados compatíveis com CHOQUE SÉPTICO (vasopressor + lactato > 2 mmol/L). Confirmar ressuscitação volêmica adequada e julgamento clínico."
        }

        // Sepse = infecção suspeita/confirmada + disfunção orgânica (ΔSOFA ≥ 2).
        // O marcador "= SEPSE" aparece apenas no texto do SOFA quando o critério (Δ ≥ 2) é atingido.
        if let sofa = paciente.ultimaMedicao(de: .sofa), sofa.interpretacao.contains("= SEPSE") {
            return "SOFA indica disfunção orgânica (Δ ≥ 2). Se infecção suspeita/confirmada, considerar SEPSE."
        }

        if vasopressorIniciado {
            return "Vasopressor em uso. Avaliar choque séptico (requer lactato > 2 mmol/L após volume adequado)."
        }
        return nil
    }
}
