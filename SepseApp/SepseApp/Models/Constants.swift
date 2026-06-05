import Foundation

/// Textos e constantes de segurança usados em todo o app.
enum AppText {
    /// Disclaimer obrigatório em todas as telas de conduta.
    static let disclaimerConduta =
        "Apoio à decisão. Confirmar com julgamento clínico, protocolos locais e equipe assistente."

    /// Aviso sobre qSOFA (não usar como triagem única; negativo não exclui sepse).
    static let avisoQSOFA =
        "qSOFA não deve ser usado como ferramenta única de triagem. Um qSOFA negativo NÃO exclui sepse. Priorize NEWS/MEWS/SIRS + avaliação clínica."

    /// Fatores a considerar na escolha do antimicrobiano empírico (não hardcodar regime universal).
    static let fatoresAntimicrobiano =
        "A escolha deve seguir o protocolo institucional/CCIH e considerar: antibiograma local, alergias, foco suspeito, função renal, função hepática e risco de MRSA/MDR/fungo."

    /// Aviso de individualização da ressuscitação volêmica.
    static let avisoFluidos =
        "30 mL/kg é uma referência inicial individualizável. Reavalie dinamicamente (elevação passiva de pernas, variação de pressão de pulso). Cautela em IC, DRC, cirrose, idosos e risco de congestão."
}
