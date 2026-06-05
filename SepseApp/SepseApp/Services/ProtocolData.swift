import Foundation

/// Fluxogramas interativos baseados nas diretrizes Surviving Sepsis Campaign 2021.
enum ProtocolData {

    static let fluxogramas: [Fluxograma] = [
        Fluxograma(numero: 1, titulo: "Triagem e reconhecimento", passos: [
            FluxogramaPasso(titulo: "Triagem: NEWS/MEWS/SIRS + avaliação clínica",
                            detalhe: "Fora da UTI, priorize NEWS/MEWS/SIRS e o exame clínico. NÃO use qSOFA como triagem única; qSOFA negativo não exclui sepse (qSOFA serve apenas como sinalizador de risco/prognóstico). Na UTI, use SOFA."),
            FluxogramaPasso(titulo: "Definir disfunção orgânica (SOFA)",
                            detalhe: "Sepse = suspeita/confirmação de infecção + disfunção orgânica, operacionalizada por aumento do SOFA ≥ 2 pontos sobre o basal (basal presumido 0 se desconhecido)."),
            FluxogramaPasso(titulo: "Coletar lactato sérico",
                            detalhe: "Lactato > 2 mmol/L → hipoperfusão presente."),
            FluxogramaPasso(titulo: "Avaliar choque séptico",
                            detalhe: "Necessidade de vasopressor para manter PAM ≥ 65 mmHg após ressuscitação volêmica adequada + lactato > 2 mmol/L = choque séptico."),
            FluxogramaPasso(titulo: "Classificar o paciente",
                            detalhe: "Infecção sem sepse, sepse ou choque séptico — confirmar com julgamento clínico.")
        ]),

        Fluxograma(numero: 2, titulo: "Ressuscitação inicial", passos: [
            FluxogramaPasso(titulo: "Antibióticos — tempo por probabilidade e gravidade",
                            detalhe: "Choque séptico ou alta probabilidade: imediato, idealmente ≤ 1 h. Possível sepse sem choque: investigação rápida e antibiótico ≤ 3 h se a suspeita persistir. Baixa probabilidade sem choque: observação/reavaliação — não forçar antibiótico. O regime é editável e segue o protocolo institucional/CCIH."),
            FluxogramaPasso(titulo: "Ressuscitação volêmica (individualizável)",
                            detalhe: "30 mL/kg de cristaloide como referência inicial para hipoperfusão/choque. Individualizar e reavaliar dinamicamente. Cautela em IC, DRC, cirrose, idosos e risco de congestão. Preferir cristaloides balanceados (Ringer lactato) sobre salina 0,9%."),
            FluxogramaPasso(titulo: "Medidas dinâmicas de resposta a fluidos",
                            detalhe: "Elevação passiva de pernas, variação de pressão de pulso para guiar a ressuscitação adicional."),
            FluxogramaPasso(titulo: "Monitorização",
                            detalhe: "Lactato sérico (repetir se elevado), tempo de enchimento capilar, débito urinário e PAM.")
        ]),

        Fluxograma(numero: 3, titulo: "Vasopressores e suporte hemodinâmico", passos: [
            FluxogramaPasso(titulo: "Norepinefrina (primeira linha)",
                            detalhe: "Iniciar 0,05–0,1 mcg/kg/min, titulando para PAM ≥ 65 mmHg. Pode ser administrada por acesso periférico calibroso ou intraósseo."),
            FluxogramaPasso(titulo: "Adicionar vasopressina",
                            detalhe: "0,03–0,04 unidades/min (dose fixa) se necessidade crescente de norepinefrina, para poupar catecolaminas."),
            FluxogramaPasso(titulo: "Adicionar epinefrina",
                            detalhe: "0,05–0,2 mcg/kg/min se hipotensão persistente."),
            FluxogramaPasso(titulo: "Considerar corticosteroides (atualização 2024)",
                            detalhe: "Apenas em CHOQUE SÉPTICO com necessidade persistente de vasopressor. Hidrocortisona em dose baixa (≈ 200 mg/dia IV). EVITAR regimes de alta dose/curta duração. NÃO usar corticoide em sepse sem choque. Decisão individualizada."),
            FluxogramaPasso(titulo: "Dobutamina apenas em disfunção miocárdica",
                            detalhe: "2,5–20 mcg/kg/min somente se hipoperfusão persistente com PAM já adequada e suspeita de disfunção miocárdica.")
        ]),

        Fluxograma(numero: 4, titulo: "Controle da fonte de infecção", passos: [
            FluxogramaPasso(titulo: "Identificar o foco",
                            detalhe: "Exame físico e exames de imagem (radiografia, ultrassom, TC)."),
            FluxogramaPasso(titulo: "Determinar a necessidade de intervenção",
                            detalhe: "Drenagem de abscessos, desbridamento de necrose, remoção de dispositivos infectados, cirurgia."),
            FluxogramaPasso(titulo: "Intervir precocemente",
                            detalhe: "O mais cedo possível após estabilização hemodinâmica.")
        ]),

        Fluxograma(numero: 5, titulo: "Ajuste e desescalonamento (48–72 h)", passos: [
            FluxogramaPasso(titulo: "Reavaliar com culturas",
                            detalhe: "Ajustar antibióticos conforme antibiograma; desescalonar para espectro mais estreito quando possível."),
            FluxogramaPasso(titulo: "Avaliar resposta clínica",
                            detalhe: "Melhora hemodinâmica, redução do lactato, resolução da febre, melhora da leucocitose."),
            FluxogramaPasso(titulo: "Suspender vasopressores",
                            detalhe: "Desmame gradual conforme estabilidade hemodinâmica."),
            FluxogramaPasso(titulo: "Suspender corticosteroides",
                            detalhe: "Após 5–7 dias ou quando o paciente estiver estável sem vasopressores.")
        ])
    ]
}
