import SwiftUI

// MARK: - qSOFA

struct QSOFAForm: View {
    let pacienteID: UUID
    @State private var input = QSOFACalculator.Input()

    private var resultado: ScoreResult { QSOFACalculator.calcular(input) }

    var body: some View {
        Section("Variáveis") {
            Stepper("Glasgow: \(input.glasgow)", value: $input.glasgow, in: 3...15)
            Stepper("FR: \(input.frequenciaRespiratoria)/min", value: $input.frequenciaRespiratoria, in: 0...60)
            Stepper("PA sistólica: \(input.pressaoSistolica) mmHg", value: $input.pressaoSistolica, in: 40...250, step: 5)
        }
        Section { ScoreResultCard(titulo: "qSOFA", resultado: resultado) }
        Section { RegistrarScoreButton(pacienteID: pacienteID, tipo: .qsofa, resultado: resultado) }
    }
}

// MARK: - SOFA

struct SOFAForm: View {
    let pacienteID: UUID
    @State private var input = SOFACalculator.Input()

    private var resultado: ScoreResult { SOFACalculator.calcular(input) }

    var body: some View {
        Section("Respiratório") {
            LabeledNumberField(titulo: "PaO₂/FiO₂", valor: $input.pao2fio2)
            Toggle("Suporte ventilatório", isOn: $input.suporteVentilatorio)
        }
        Section("Coagulação / Hepático") {
            LabeledNumberField(titulo: "Plaquetas (x10³/µL)", valor: $input.plaquetas)
            LabeledNumberField(titulo: "Bilirrubina (mg/dL)", valor: $input.bilirrubina)
        }
        Section("Cardiovascular (catecolaminas em mcg/kg/min)") {
            LabeledNumberField(titulo: "PAM (mmHg)", valor: $input.pam)
            LabeledNumberField(titulo: "Dopamina", valor: $input.dopamina)
            Toggle("Dobutamina (qualquer dose)", isOn: $input.dobutamina)
            LabeledNumberField(titulo: "Epinefrina", valor: $input.epinefrina)
            LabeledNumberField(titulo: "Norepinefrina", valor: $input.norepinefrina)
        }
        Section("Neurológico / Renal") {
            Stepper("Glasgow: \(input.glasgow)", value: $input.glasgow, in: 3...15)
            LabeledNumberField(titulo: "Creatinina (mg/dL)", valor: $input.creatinina)
            LabeledOptionalNumberField(titulo: "Débito urinário (mL/dia)", valor: $input.debitoUrinario)
        }
        Section("Basal") {
            Stepper("SOFA basal: \(input.sofaBasal)", value: $input.sofaBasal, in: 0...24)
        }
        Section { ScoreResultCard(titulo: "SOFA", resultado: resultado) }
        Section { RegistrarScoreButton(pacienteID: pacienteID, tipo: .sofa, resultado: resultado) }
    }
}

// MARK: - SIRS

struct SIRSForm: View {
    let pacienteID: UUID
    @State private var input = SIRSCalculator.Input()

    private var resultado: ScoreResult { SIRSCalculator.calcular(input) }

    var body: some View {
        Section("Variáveis") {
            LabeledNumberField(titulo: "Temperatura (°C)", valor: $input.temperatura)
            Stepper("FC: \(input.frequenciaCardiaca) bpm", value: $input.frequenciaCardiaca, in: 0...250, step: 5)
            Stepper("FR: \(input.frequenciaRespiratoria)/min", value: $input.frequenciaRespiratoria, in: 0...60)
            LabeledOptionalNumberField(titulo: "PaCO₂ (mmHg)", valor: $input.paco2)
            LabeledNumberField(titulo: "Leucócitos (/mm³)", valor: $input.leucocitos)
            LabeledNumberField(titulo: "Bastões (%)", valor: $input.bastoes)
        }
        Section { ScoreResultCard(titulo: "SIRS", resultado: resultado) }
        Section { RegistrarScoreButton(pacienteID: pacienteID, tipo: .sirs, resultado: resultado) }
    }
}

// MARK: - NEWS

struct NEWSForm: View {
    let pacienteID: UUID
    @State private var input = NEWSCalculator.Input()

    private var resultado: ScoreResult { NEWSCalculator.calcular(input) }

    var body: some View {
        Section("Variáveis") {
            Stepper("FR: \(input.frequenciaRespiratoria)/min", value: $input.frequenciaRespiratoria, in: 0...60)
            Stepper("SpO₂: \(input.spo2)%", value: $input.spo2, in: 50...100)
            Toggle("O₂ suplementar", isOn: $input.oxigenioSuplementar)
            LabeledNumberField(titulo: "Temperatura (°C)", valor: $input.temperatura)
            Stepper("PA sistólica: \(input.pressaoSistolica) mmHg", value: $input.pressaoSistolica, in: 40...250, step: 5)
            Stepper("FC: \(input.frequenciaCardiaca) bpm", value: $input.frequenciaCardiaca, in: 0...250, step: 5)
            Picker("Consciência (AVPU)", selection: $input.consciencia) {
                ForEach(NivelAVPU.allCases) { Text($0.rawValue).tag($0) }
            }
        }
        Section { ScoreResultCard(titulo: "NEWS", resultado: resultado) }
        Section { RegistrarScoreButton(pacienteID: pacienteID, tipo: .news, resultado: resultado) }
    }
}

// MARK: - MEDS

struct MEDSForm: View {
    let pacienteID: UUID
    @State private var input = MEDSCalculator.Input()

    private var resultado: ScoreResult { MEDSCalculator.calcular(input) }

    var body: some View {
        Section {
            Label("MEDS adaptado: usa as variáveis do protocolo deste app (inclui lactato e origem hospitalar). NÃO é o MEDS validado original (que pontua doença terminal). Interprete a categoria de risco com cautela.",
                  systemImage: "info.circle")
                .font(.caption).foregroundColor(.secondary)
        }
        Section("Critérios") {
            Toggle("Idade > 65 anos", isOn: $input.idadeMaior65)
            Toggle("Bandas > 5%", isOn: $input.bandasMaior5)
            Toggle("Taquipneia / hipoxemia", isOn: $input.taquipneia)
            Toggle("Choque séptico", isOn: $input.choqueSeptico)
            Toggle("Plaquetas < 150.000/µL", isOn: $input.plaquetasBaixas)
            Toggle("Lactato > 2,5 mmol/L", isOn: $input.lactatoElevado)
            Toggle("Alteração do estado mental", isOn: $input.alteracaoEstadoMental)
            Toggle("Infecção de origem hospitalar", isOn: $input.infeccaoHospitalar)
            Toggle("Residência em ILPI", isOn: $input.residenciaILPI)
        }
        Section { ScoreResultCard(titulo: "MEDS", resultado: resultado) }
        Section { RegistrarScoreButton(pacienteID: pacienteID, tipo: .meds, resultado: resultado) }
    }
}

// MARK: - APACHE II

struct APACHEIIForm: View {
    let pacienteID: UUID
    @State private var input = APACHEIICalculator.Input()

    private var resultado: ScoreResult { APACHEIICalculator.calcular(input) }

    var body: some View {
        Section("Sinais vitais") {
            LabeledNumberField(titulo: "Temperatura (°C)", valor: $input.temperatura)
            LabeledNumberField(titulo: "PAM (mmHg)", valor: $input.pam)
            Stepper("FC: \(input.frequenciaCardiaca) bpm", value: $input.frequenciaCardiaca, in: 0...250, step: 5)
            Stepper("FR: \(input.frequenciaRespiratoria)/min", value: $input.frequenciaRespiratoria, in: 0...60)
        }
        Section("Oxigenação") {
            LabeledNumberField(titulo: "FiO₂ (0–1)", valor: $input.fio2)
            if input.fio2 >= 0.5 {
                LabeledNumberField(titulo: "A-aDO₂ (mmHg)", valor: $input.aadO2)
            } else {
                LabeledNumberField(titulo: "PaO₂ (mmHg)", valor: $input.pao2)
            }
        }
        Section("Laboratório") {
            LabeledNumberField(titulo: "pH arterial", valor: $input.ph)
            LabeledNumberField(titulo: "Sódio (mmol/L)", valor: $input.sodio)
            LabeledNumberField(titulo: "Potássio (mmol/L)", valor: $input.potassio)
            LabeledNumberField(titulo: "Creatinina (mg/dL)", valor: $input.creatinina)
            Toggle("Insuficiência renal aguda (dobra creatinina)", isOn: $input.insuficienciaRenalAguda)
            LabeledNumberField(titulo: "Hematócrito (%)", valor: $input.hematocrito)
            LabeledNumberField(titulo: "Leucócitos (x10³/mm³)", valor: $input.leucocitos)
        }
        Section("Neurológico / Crônico") {
            Stepper("Glasgow: \(input.glasgow)", value: $input.glasgow, in: 3...15)
            Stepper("Idade: \(input.idade) anos", value: $input.idade, in: 0...120)
            Picker("Saúde crônica", selection: $input.condicaoCronica) {
                ForEach(APACHEIICalculator.CondicaoCronica.allCases) { Text($0.rawValue).tag($0) }
            }
        }
        Section { ScoreResultCard(titulo: "APACHE II", resultado: resultado) }
        Section { RegistrarScoreButton(pacienteID: pacienteID, tipo: .apacheII, resultado: resultado) }
    }
}
