import Foundation

/// Representa um alerta clínico exibido na interface.
struct ClinicalAlert: Identifiable, Equatable {
    enum Severidade {
        case critico
        case atencao
        case info
    }
    var id = UUID()
    var titulo: String
    var mensagem: String
    var severidade: Severidade
}

/// Geração de alertas clínicos derivados do estado atual do paciente.
enum AlertService {

    /// Janela-alvo (em segundos) para administração de antibiótico, segundo probabilidade e gravidade (SSC 2021).
    /// - Choque séptico ou alta probabilidade: ≤ 1 hora.
    /// - Possível sepse sem choque: ≤ 3 horas (após investigação rápida, se a suspeita persistir).
    /// - Baixa probabilidade sem choque: nil (permitir observação/reavaliação — não forçar antibiótico).
    static func janelaAntibioticoSegundos(para paciente: Patient) -> TimeInterval? {
        if paciente.classificacao == .choqueSeptico || paciente.probabilidadeInfeccao == .alta {
            return 3600
        }
        if paciente.probabilidadeInfeccao == .baixa {
            return nil
        }
        // Possível/incerta (ou ainda não avaliada) sem choque: janela de 3 horas.
        return 3 * 3600
    }

    /// Mantido para compatibilidade com exibições genéricas (meta padrão de 1 hora).
    static let prazoAntibioticoSegundos: TimeInterval = 3600

    static func alertas(para paciente: Patient, agora: Date = Date()) -> [ClinicalAlert] {
        var lista: [ClinicalAlert] = []

        // Alergia a antimicrobiano (lembrete permanente)
        if !paciente.alergiasClasses.isEmpty {
            let nomes = paciente.alergiasClasses.map { $0.rawValue }.sorted().joined(separator: ", ")
            lista.append(ClinicalAlert(
                titulo: "Alergia a antibiótico",
                mensagem: "Alergia registrada: \(nomes). Verifique conflitos ao escolher o antimicrobiano.",
                severidade: .atencao))
        }

        // qSOFA ≥ 2
        if let q = paciente.ultimaMedicao(de: .qsofa), q.total >= 2 {
            lista.append(ClinicalAlert(
                titulo: "qSOFA ≥ 2",
                mensagem: "Alto risco de mortalidade. Avaliar disfunção orgânica com SOFA completo.",
                severidade: .critico))
        }

        // SOFA: o critério de sepse (Δ ≥ 2) já é refletido na cor da medição.
        if let s = paciente.ultimaMedicao(de: .sofa), s.gravidade == .vermelho || s.gravidade == .amarelo {
            lista.append(ClinicalAlert(
                titulo: "SOFA elevado",
                mensagem: s.interpretacao,
                severidade: s.gravidade == .vermelho ? .critico : .atencao))
        }

        // NEWS: deterioração clínica (triagem priorizada fora da UTI).
        if let n = paciente.ultimaMedicao(de: .news) {
            if n.total >= 7 {
                lista.append(ClinicalAlert(
                    titulo: "NEWS ≥ 7",
                    mensagem: "Risco alto de deterioração. Resposta de emergência e avaliação por terapia intensiva.",
                    severidade: .critico))
            } else if n.total >= 5 {
                lista.append(ClinicalAlert(
                    titulo: "NEWS 5–6",
                    mensagem: "Risco aumentado. Avaliação clínica urgente. Lembrar: qSOFA negativo não exclui sepse.",
                    severidade: .atencao))
            }
        }

        // Lactato (valor numérico) — hipoperfusão.
        if let lac = paciente.lactato {
            if lac > 4 {
                lista.append(ClinicalAlert(
                    titulo: "Lactato > 4 mmol/L",
                    mensagem: "Hipoperfusão grave. Ressuscitar e repetir lactato. Isoladamente NÃO define choque (que exige vasopressor após volume).",
                    severidade: .critico))
            } else if lac > 2 {
                lista.append(ClinicalAlert(
                    titulo: "Lactato 2–4 mmol/L",
                    mensagem: "Hipoperfusão. Repetir lactato e reavaliar perfusão (enchimento capilar, débito urinário).",
                    severidade: .atencao))
            }
        } else if paciente.eventos.contains(where: { $0.tipo == .lactato }) {
            lista.append(ClinicalAlert(
                titulo: "Registrar valor do lactato",
                mensagem: "Coleta de lactato registrada sem valor numérico. Informe o lactato (mmol/L) no perfil para avaliação automática.",
                severidade: .info))
        }

        // Lembrete de antibiótico — janela conforme probabilidade e gravidade (SSC 2021)
        if let reconhecimento = paciente.reconhecimentoSepse {
            let administrou = paciente.eventos.contains { $0.tipo == .antibiotico }
            if !administrou {
                if let janela = janelaAntibioticoSegundos(para: paciente) {
                    let decorrido = agora.timeIntervalSince(reconhecimento)
                    let restante = janela - decorrido
                    let metaTexto = janela <= 3600 ? "1 hora" : "3 horas"
                    if restante <= 0 {
                        lista.append(ClinicalAlert(
                            titulo: "Antibiótico ATRASADO",
                            mensagem: "Ultrapassada a janela de \(metaTexto) desde o reconhecimento sem antibiótico administrado.",
                            severidade: .critico))
                    } else {
                        let min = Int(restante / 60)
                        lista.append(ClinicalAlert(
                            titulo: "Administrar antibiótico",
                            mensagem: "Janela de \(metaTexto): restam ~\(min) min. Confirmar indicação clínica.",
                            severidade: .atencao))
                    }
                } else {
                    // Baixa probabilidade sem choque: não forçar antibiótico.
                    lista.append(ClinicalAlert(
                        titulo: "Reavaliar antes de antibiótico",
                        mensagem: "Baixa probabilidade de infecção sem choque: considerar observação/investigação e reavaliação. Não forçar antibiótico empírico.",
                        severidade: .info))
                }
            }
        }

        return lista
    }
}
