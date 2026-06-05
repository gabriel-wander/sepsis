import SwiftUI

/// Formulário de cadastro/edição do perfil do paciente.
struct PatientFormView: View {
    enum Modo: Equatable {
        case novo
        case editar(Patient)
    }

    @EnvironmentObject var store: DataStore
    @Environment(\.dismiss) private var dismiss

    let modo: Modo
    @State private var paciente: Patient

    init(modo: Modo) {
        self.modo = modo
        switch modo {
        case .novo:
            _paciente = State(initialValue: Patient())
        case .editar(let p):
            _paciente = State(initialValue: p)
        }
    }

    private var titulo: String {
        if case .novo = modo { return "Novo Paciente" }
        return "Editar Paciente"
    }

    var body: some View {
        Form {
            Section("Dados demográficos") {
                TextField("Nome / Identificador", text: $paciente.nome)
                    .accessibilityIdentifier("patientName")
                Stepper("Idade: \(paciente.idade) anos", value: $paciente.idade, in: 0...120)
                Picker("Sexo", selection: $paciente.sexo) {
                    ForEach(Sexo.allCases) { Text($0.rawValue).tag($0) }
                }
                LabeledNumberField(titulo: "Peso (kg)", valor: $paciente.pesoKg)
                LabeledNumberField(titulo: "Altura (cm)", valor: $paciente.alturaCm)
                if let imc = paciente.imc {
                    LabeledContent("IMC", value: String(format: "%.1f kg/m²", imc))
                }
            }

            Section("Localização") {
                Picker("Ambiente de atendimento", selection: $paciente.ambiente) {
                    ForEach(AmbienteAtendimento.allCases) { Text($0.rawValue).tag($0) }
                }
                Picker("Local de aquisição", selection: $paciente.localAquisicao) {
                    ForEach(LocalAquisicao.allCases) { Text($0.rawValue).tag($0) }
                }
            }

            Section("Comorbidades") {
                ForEach(Comorbidade.allCases) { c in
                    Toggle(c.rawValue, isOn: Binding(
                        get: { paciente.comorbidades.contains(c) },
                        set: { on in
                            if on { paciente.comorbidades.insert(c) } else { paciente.comorbidades.remove(c) }
                        }))
                }
            }

            Section("Antimicrobianos prévios") {
                Toggle("Uso nos últimos 30 dias", isOn: $paciente.usouAntibioticos30Dias)
                if paciente.usouAntibioticos30Dias {
                    TextField("Quais", text: $paciente.antibioticosRecentes, axis: .vertical)
                }
            }

            Section("Colonização por multirresistentes") {
                ForEach(OrganismoMDR.allCases) { o in
                    Toggle(o.rawValue, isOn: Binding(
                        get: { paciente.colonizacaoMDR.contains(o) },
                        set: { on in
                            if on { paciente.colonizacaoMDR.insert(o) } else { paciente.colonizacaoMDR.remove(o) }
                        }))
                }
            }

            Section("Alergias medicamentosas") {
                TextField("Descreva as alergias", text: $paciente.alergias, axis: .vertical)
            }

            Section {
                ForEach(ClasseAntibiotico.allCases) { classe in
                    Toggle(classe.rawValue, isOn: Binding(
                        get: { paciente.alergiasClasses.contains(classe) },
                        set: { on in
                            if on { paciente.alergiasClasses.insert(classe) } else { paciente.alergiasClasses.remove(classe) }
                        }))
                }
            } header: {
                Text("Alergia por classe de antibiótico")
            } footer: {
                Text("Usado para alertar conflitos entre alergia e antimicrobianos/regimes sugeridos.")
            }

            Section("Função renal e hepática") {
                LabeledOptionalNumberField(titulo: "Creatinina sérica (mg/dL)", valor: $paciente.creatininaSerica)
                LabeledOptionalNumberField(titulo: "Clearance estimado (mL/min)", valor: $paciente.clearanceEstimado)
                if let cl = paciente.clearanceCalculado {
                    LabeledContent("ClCr (Cockcroft-Gault)", value: String(format: "%.0f mL/min", cl))
                }
                LabeledOptionalNumberField(titulo: "Bilirrubinas (mg/dL)", valor: $paciente.bilirrubinas)
                TextField("Transaminases (TGO/TGP)", text: $paciente.transaminases)
            }

            Section {
                LabeledOptionalNumberField(titulo: "Lactato (mmol/L)", valor: $paciente.lactato)
            } header: {
                Text("Perfusão")
            } footer: {
                Text("Lactato > 2 mmol/L indica hipoperfusão. Isoladamente NÃO define choque (que exige vasopressor após volume).")
            }
        }
        .navigationTitle(titulo)
        .toolbar {
            ToolbarItem(placement: .cancellationAction) {
                Button("Cancelar") { dismiss() }
            }
            ToolbarItem(placement: .confirmationAction) {
                Button("Salvar") { salvar() }
                    .disabled(paciente.nome.trimmingCharacters(in: .whitespaces).isEmpty)
                    .accessibilityIdentifier("savePatient")
            }
        }
    }

    private func salvar() {
        switch modo {
        case .novo:
            store.adicionar(paciente)
        case .editar:
            store.atualizar(paciente)
        }
        dismiss()
    }
}

// MARK: - Campos numéricos reutilizáveis

struct LabeledNumberField: View {
    let titulo: String
    @Binding var valor: Double

    var body: some View {
        HStack {
            Text(titulo)
            Spacer()
            TextField(titulo, value: $valor, format: .number)
                .keyboardType(.decimalPad)
                .multilineTextAlignment(.trailing)
                .frame(maxWidth: 120)
        }
    }
}

struct LabeledOptionalNumberField: View {
    let titulo: String
    @Binding var valor: Double?

    var body: some View {
        HStack {
            Text(titulo)
            Spacer()
            TextField("—", value: $valor, format: .number)
                .keyboardType(.decimalPad)
                .multilineTextAlignment(.trailing)
                .frame(maxWidth: 120)
        }
    }
}
