import SwiftUI
#if canImport(UIKit)
import UIKit
#endif

// MARK: - Mapeamento de cor de gravidade

extension GravidadeCor {
    var cor: Color {
        switch self {
        case .verde: return .green
        case .amarelo: return .orange
        case .vermelho: return .red
        case .cinza: return .gray
        }
    }

    var rotulo: String {
        switch self {
        case .verde: return "Estável"
        case .amarelo: return "Atenção"
        case .vermelho: return "Crítico"
        case .cinza: return "Sem dados"
        }
    }
}

// MARK: - Indicador de gravidade (círculo colorido)

struct SeverityDot: View {
    let gravidade: GravidadeCor
    var diametro: CGFloat = 14

    var body: some View {
        Circle()
            .fill(gravidade.cor)
            .frame(width: diametro, height: diametro)
            .accessibilityLabel(gravidade.rotulo)
    }
}

// MARK: - Cartão de resultado de score

struct ScoreResultCard: View {
    let titulo: String
    let resultado: ScoreResult

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text(titulo).font(.headline)
                Spacer()
                Text("\(resultado.total)")
                    .font(.system(size: 34, weight: .bold, design: .rounded))
                    .foregroundColor(resultado.gravidade.cor)
            }
            Text(resultado.interpretacao)
                .font(.subheadline)
                .foregroundColor(.secondary)
                .fixedSize(horizontal: false, vertical: true)

            if !resultado.componentes.isEmpty {
                Divider()
                ForEach(resultado.componentes.indices, id: \.self) { i in
                    HStack {
                        Text(resultado.componentes[i].0)
                            .font(.caption)
                        Spacer()
                        Text("\(resultado.componentes[i].1)")
                            .font(.caption.monospacedDigit())
                            .foregroundColor(resultado.componentes[i].1 > 0 ? resultado.gravidade.cor : .secondary)
                    }
                }
            }
        }
        .padding()
        .background(resultado.gravidade.cor.opacity(0.10))
        .clipShape(RoundedRectangle(cornerRadius: 12))
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(resultado.gravidade.cor.opacity(0.4), lineWidth: 1)
        )
    }
}

// MARK: - Banner de apoio à decisão (obrigatório nas telas de conduta)

struct DisclaimerBanner: View {
    var texto: String = AppText.disclaimerConduta

    var body: some View {
        HStack(alignment: .top, spacing: 8) {
            Image(systemName: "stethoscope.circle.fill")
                .foregroundColor(.accentColor)
            Text(texto)
                .font(.caption)
                .foregroundColor(.secondary)
                .fixedSize(horizontal: false, vertical: true)
        }
        .padding(10)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color.accentColor.opacity(0.10))
        .clipShape(RoundedRectangle(cornerRadius: 10))
        .accessibilityElement(children: .combine)
    }
}

// MARK: - Cartão de alerta

struct AlertCard: View {
    let alerta: ClinicalAlert

    private var cor: Color {
        switch alerta.severidade {
        case .critico: return .red
        case .atencao: return .orange
        case .info: return .blue
        }
    }

    private var simbolo: String {
        switch alerta.severidade {
        case .critico: return "exclamationmark.octagon.fill"
        case .atencao: return "exclamationmark.triangle.fill"
        case .info: return "info.circle.fill"
        }
    }

    var body: some View {
        HStack(alignment: .top, spacing: 10) {
            Image(systemName: simbolo).foregroundColor(cor)
            VStack(alignment: .leading, spacing: 2) {
                Text(alerta.titulo).font(.subheadline.bold())
                Text(alerta.mensagem).font(.caption).foregroundColor(.secondary)
                    .fixedSize(horizontal: false, vertical: true)
            }
            Spacer()
        }
        .padding(10)
        .background(cor.opacity(0.12))
        .clipShape(RoundedRectangle(cornerRadius: 10))
    }
}

// MARK: - Gráfico simples de evolução de score (sem dependências externas)

struct ScoreLineChart: View {
    let medicoes: [ScoreMeasurement]
    let maximo: Int

    var body: some View {
        GeometryReader { geo in
            let pontos = posicoes(in: geo.size)
            ZStack {
                // Linha de base
                Path { p in
                    p.move(to: CGPoint(x: 0, y: geo.size.height))
                    p.addLine(to: CGPoint(x: geo.size.width, y: geo.size.height))
                }.stroke(Color.secondary.opacity(0.3), lineWidth: 1)

                // Linha do gráfico
                Path { p in
                    guard let primeiro = pontos.first else { return }
                    p.move(to: primeiro)
                    for ponto in pontos.dropFirst() { p.addLine(to: ponto) }
                }.stroke(Color.accentColor, lineWidth: 2)

                // Marcadores
                ForEach(pontos.indices, id: \.self) { i in
                    Circle()
                        .fill(medicoes[i].gravidade.cor)
                        .frame(width: 8, height: 8)
                        .position(pontos[i])
                }
            }
        }
        .frame(height: 120)
        .accessibilityLabel("Gráfico de evolução do score ao longo do tempo")
    }

    private func posicoes(in size: CGSize) -> [CGPoint] {
        guard !medicoes.isEmpty else { return [] }
        let maxV = max(maximo, 1)
        let n = medicoes.count
        return medicoes.enumerated().map { idx, m in
            let x = n == 1 ? size.width / 2 : size.width * CGFloat(idx) / CGFloat(n - 1)
            let y = size.height * (1 - CGFloat(m.total) / CGFloat(maxV))
            return CGPoint(x: x, y: y)
        }
    }
}

// MARK: - Compartilhamento (UIActivityViewController)

#if canImport(UIKit)
struct ShareSheet: UIViewControllerRepresentable {
    let itens: [Any]
    func makeUIViewController(context: Context) -> UIActivityViewController {
        UIActivityViewController(activityItems: itens, applicationActivities: nil)
    }
    func updateUIViewController(_ uiViewController: UIActivityViewController, context: Context) {}
}
#endif
