import Foundation

/// Banco de dados estático de antimicrobianos e regimes empíricos, disponível offline.
enum AntimicrobialDatabase {

    static let antimicrobianos: [Antimicrobial] = [
        Antimicrobial(
            nome: "Ceftriaxona",
            classe: "Cefalosporina de 3ª geração",
            espectro: "Gram-positivos (exceto MRSA/Enterococcus), Gram-negativos comunitários, pneumococo.",
            doseUsual: "1–2 g IV 24/24h",
            ajusteRenal: "Não requer ajuste por função renal.",
            contraindicacoes: "Alergia a betalactâmicos. Cautela em neonatos com hiperbilirrubinemia.",
            interacoes: "Soluções com cálcio IV (precipitação) em neonatos."
        ),
        Antimicrobial(
            nome: "Piperacilina-tazobactam",
            classe: "Penicilina + inibidor de betalactamase",
            espectro: "Amplo: Gram-positivos, Gram-negativos incluindo Pseudomonas, anaeróbios.",
            doseUsual: "4,5 g IV 6/6h",
            ajusteRenal: "ClCr 20–40: 3,375 g 6/6h. ClCr <20: 2,25 g 6/6h.",
            contraindicacoes: "Alergia a betalactâmicos.",
            interacoes: "Risco de nefrotoxicidade com vancomicina; prolonga bloqueio neuromuscular."
        ),
        Antimicrobial(
            nome: "Meropenem",
            classe: "Carbapenêmico",
            espectro: "Muito amplo, incluindo ESBL e Pseudomonas. Não cobre MRSA nem Enterococcus faecium.",
            doseUsual: "1 g IV 8/8h",
            ajusteRenal: "ClCr 25–50: 1 g 12/12h. ClCr 10–25: 0,5 g 12/12h. ClCr <10: 0,5 g 24/24h.",
            contraindicacoes: "Alergia a carbapenêmicos.",
            interacoes: "Reduz níveis de valproato (risco de convulsões)."
        ),
        Antimicrobial(
            nome: "Vancomicina",
            classe: "Glicopeptídeo",
            espectro: "Gram-positivos, incluindo MRSA e Enterococcus sensível.",
            doseUsual: "15–20 mg/kg IV 8–12/12h (alvo vale 15–20 µg/mL)",
            ajusteRenal: "Ajustar intervalo por ClCr e monitorar nível sérico (vale).",
            contraindicacoes: "Hipersensibilidade. Cautela em nefropatas.",
            interacoes: "Nefrotoxicidade aditiva com aminoglicosídeos/piperacilina-tazobactam.",
            dosePorPeso: true,
            mgPorKg: 17.5
        ),
        Antimicrobial(
            nome: "Cefepima",
            classe: "Cefalosporina de 4ª geração",
            espectro: "Gram-negativos incluindo Pseudomonas; útil em neutropenia febril.",
            doseUsual: "2 g IV 8/8h",
            ajusteRenal: "ClCr 30–60: 2 g 12/12h. ClCr 11–29: 2 g 24/24h.",
            contraindicacoes: "Alergia a betalactâmicos. Risco de neurotoxicidade em DRC.",
            interacoes: "Neurotoxicidade aumentada em insuficiência renal não ajustada."
        ),
        Antimicrobial(
            nome: "Azitromicina",
            classe: "Macrolídeo",
            espectro: "Atípicos (Legionella, Mycoplasma, Chlamydophila); adjuvante em PAC.",
            doseUsual: "500 mg IV/VO 24/24h",
            ajusteRenal: "Não requer ajuste renal.",
            contraindicacoes: "Hipersensibilidade a macrolídeos. Cautela em QT longo.",
            interacoes: "Prolongamento do intervalo QT com outros fármacos QT-prolongadores."
        ),
        Antimicrobial(
            nome: "Ciprofloxacino",
            classe: "Fluoroquinolona",
            espectro: "Gram-negativos incluindo Pseudomonas; cobertura limitada de Gram-positivos.",
            doseUsual: "400 mg IV 12/12h",
            ajusteRenal: "ClCr 30–50: 400 mg 12/12h. ClCr 5–29: 400 mg 24/24h.",
            contraindicacoes: "História de tendinopatia por quinolonas; cautela em QT longo.",
            interacoes: "Quelação com cátions (Ca, Mg, Fe); aumenta efeito de tizanidina/teofilina."
        ),
        Antimicrobial(
            nome: "Metronidazol",
            classe: "Nitroimidazol",
            espectro: "Anaeróbios e protozoários. Associado em infecções intra-abdominais.",
            doseUsual: "500 mg IV 8/8h",
            ajusteRenal: "Sem ajuste renal; reduzir em insuficiência hepática grave.",
            contraindicacoes: "Primeiro trimestre de gestação (relativo).",
            interacoes: "Efeito dissulfiram-símile com álcool; potencializa varfarina."
        )
    ]

    /// Exemplos de regimes empíricos pré-carregados na primeira execução.
    /// São apenas pontos de partida e DEVEM ser revisados/substituídos pelo protocolo institucional/CCIH.
    static func defaultRegimes() -> [EmpiricRegimen] {
        [
            EmpiricRegimen(contexto: "Pneumonia comunitária",
                           regime: "Ex.: Ceftriaxona 1–2 g IV 24/24h + Azitromicina 500 mg IV 24/24h",
                           observacao: "Ajustar ao protocolo local e gravidade."),
            EmpiricRegimen(contexto: "Infecção do trato urinário",
                           regime: "Ex.: Ceftriaxona 1–2 g IV 24/24h OU Ciprofloxacino 400 mg IV 12/12h",
                           observacao: "Considerar resistência local de E. coli."),
            EmpiricRegimen(contexto: "Infecção intra-abdominal",
                           regime: "Ex.: Piperacilina-tazobactam 4,5 g IV 6/6h OU Meropenem 1 g IV 8/8h",
                           observacao: "Cobrir anaeróbios; avaliar controle de foco."),
            EmpiricRegimen(contexto: "Origem hospitalar / risco de MDR",
                           regime: "Ex.: Piperacilina-tazobactam 4,5 g IV 6/6h + Vancomicina 15–20 mg/kg IV 8–12/12h",
                           observacao: "Guiar por antibiograma local e colonização prévia."),
            EmpiricRegimen(contexto: "Neutropenia febril",
                           regime: "Ex.: Cefepima 2 g IV 8/8h OU Meropenem 1 g IV 8/8h",
                           observacao: "Avaliar cobertura antifúngica conforme risco.")
        ]
    }

    /// Destaca, entre os regimes institucionais informados, os contextos potencialmente relevantes
    /// para o perfil do paciente — apenas como auxílio de navegação, sem recomendar esquema universal.
    static func contextosRelevantes(para paciente: Patient) -> Set<String> {
        var relevantes = Set<String>()
        let temMDR = !paciente.colonizacaoMDR.isEmpty
            || paciente.localAquisicao == .hospitalar
            || paciente.usouAntibioticos30Dias
        if temMDR { relevantes.insert("MDR") }
        if paciente.comorbidades.contains(.imunossupressao) || paciente.comorbidades.contains(.neoplasia) {
            relevantes.insert("Neutropenia")
        }
        return relevantes
    }
}
