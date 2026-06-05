import Foundation
#if canImport(UIKit)
import UIKit

/// Gera um relatório PDF com a evolução do paciente para compartilhamento com a equipe.
enum PDFExporter {

    private static let pageWidth: CGFloat = 612   // 8,5"
    private static let pageHeight: CGFloat = 792  // 11"
    private static let margin: CGFloat = 40

    static func gerarRelatorio(para paciente: Patient) -> URL? {
        let renderer = UIGraphicsPDFRenderer(bounds: CGRect(x: 0, y: 0, width: pageWidth, height: pageHeight))

        let df = DateFormatter()
        df.dateFormat = "dd/MM/yyyy HH:mm"

        let dados = renderer.pdfData { ctx in
            ctx.beginPage()
            var y: CGFloat = margin

            y = desenharTitulo("Relatório de Sepse — \(paciente.nome.isEmpty ? "Paciente" : paciente.nome)", em: y)
            y = desenharLinha("Gerado em \(df.string(from: Date()))", em: y, fonte: .systemFont(ofSize: 10))
            y += 8

            y = desenharSecao("Dados demográficos", em: y)
            y = desenharLinha("Idade: \(paciente.idade) anos   Sexo: \(paciente.sexo.rawValue)", em: y)
            y = desenharLinha(String(format: "Peso: %.1f kg   Altura: %.0f cm   IMC: %@",
                                     paciente.pesoKg, paciente.alturaCm,
                                     paciente.imc.map { String(format: "%.1f", $0) } ?? "—"), em: y)
            y = desenharLinha("Ambiente: \(paciente.ambiente.rawValue)   Aquisição: \(paciente.localAquisicao.rawValue)", em: y)
            y += 8

            y = desenharSecao("Classificação clínica", em: y)
            y = desenharLinha("\(paciente.classificacao.rawValue) · \(paciente.probabilidadeInfeccao.rawValue)", em: y)
            if let rec = paciente.reconhecimentoSepse {
                y = desenharLinha("Reconhecimento de sepse: \(df.string(from: rec))", em: y)
            }
            y += 8

            y = desenharSecao("Comorbidades", em: y)
            let comorb = paciente.comorbidades.map { $0.rawValue }.sorted().joined(separator: ", ")
            y = desenharLinha(comorb.isEmpty ? "Nenhuma registrada" : comorb, em: y)
            y += 8

            y = desenharSecao("Alergias e perfusão", em: y)
            let alergiasClasses = paciente.alergiasClasses.map { $0.rawValue }.sorted().joined(separator: ", ")
            let alergiaTexto = [paciente.alergias, alergiasClasses].filter { !$0.isEmpty }.joined(separator: " · ")
            y = desenharLinha("Alergias: \(alergiaTexto.isEmpty ? "Nenhuma registrada" : alergiaTexto)", em: y)
            y = desenharLinha("Lactato: \(paciente.lactato.map { String(format: "%.1f mmol/L", $0) } ?? "—")", em: y)
            y += 8

            y = desenharSecao("Scores registrados", em: y)
            for tipo in TipoScore.allCases {
                if let m = paciente.ultimaMedicao(de: tipo) {
                    y = desenharLinha("\(tipo.rawValue): \(m.total) — \(df.string(from: m.data))", em: y, fonte: .boldSystemFont(ofSize: 11))
                    y = desenharLinha(m.interpretacao, em: y, fonte: .systemFont(ofSize: 9), indent: 12)
                }
                if y > pageHeight - margin - 60 { ctx.beginPage(); y = margin }
            }
            y += 8

            y = desenharSecao("Linha do tempo", em: y)
            for ev in paciente.eventos.sorted(by: { $0.data < $1.data }) {
                let texto = "\(df.string(from: ev.data)) — \(ev.tipo.rawValue)\(ev.detalhe.isEmpty ? "" : ": \(ev.detalhe)")"
                y = desenharLinha(texto, em: y, fonte: .systemFont(ofSize: 10))
                if y > pageHeight - margin - 40 { ctx.beginPage(); y = margin }
            }

            y += 16
            _ = desenharLinha(AppText.disclaimerConduta + " Surviving Sepsis Campaign 2021; corticosteroides conforme atualização 2024.",
                              em: y, fonte: .italicSystemFont(ofSize: 8))
        }

        let url = FileManager.default.temporaryDirectory
            .appendingPathComponent("Relatorio-Sepse-\(paciente.id.uuidString.prefix(8)).pdf")
        do {
            try dados.write(to: url)
            return url
        } catch {
            print("Falha ao gravar PDF: \(error)")
            return nil
        }
    }

    // MARK: - Helpers de desenho

    @discardableResult
    private static func desenharTitulo(_ texto: String, em y: CGFloat) -> CGFloat {
        desenhar(texto, em: y, fonte: .boldSystemFont(ofSize: 18))
    }

    @discardableResult
    private static func desenharSecao(_ texto: String, em y: CGFloat) -> CGFloat {
        desenhar(texto, em: y + 4, fonte: .boldSystemFont(ofSize: 13))
    }

    @discardableResult
    private static func desenharLinha(_ texto: String, em y: CGFloat, fonte: UIFont = .systemFont(ofSize: 11), indent: CGFloat = 0) -> CGFloat {
        desenhar(texto, em: y, fonte: fonte, indent: indent)
    }

    @discardableResult
    private static func desenhar(_ texto: String, em y: CGFloat, fonte: UIFont, indent: CGFloat = 0) -> CGFloat {
        let attrs: [NSAttributedString.Key: Any] = [.font: fonte, .foregroundColor: UIColor.black]
        let larguraDisponivel = pageWidth - 2 * margin - indent
        let bounding = (texto as NSString).boundingRect(
            with: CGSize(width: larguraDisponivel, height: .greatestFiniteMagnitude),
            options: [.usesLineFragmentOrigin, .usesFontLeading],
            attributes: attrs, context: nil)
        let rect = CGRect(x: margin + indent, y: y, width: larguraDisponivel, height: bounding.height)
        (texto as NSString).draw(in: rect, withAttributes: attrs)
        return y + bounding.height + 4
    }
}
#endif
