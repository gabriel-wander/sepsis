import Foundation

/// Decodificação resiliente do `Patient`.
///
/// Implementada em uma extensão (não no corpo do struct) para **preservar** o inicializador
/// `Patient()` e o memberwise init. Cada campo é lido com `decodeIfPresent`, recorrendo ao valor
/// padrão quando ausente — assim, acrescentar novos campos ao modelo **não invalida** os pacientes
/// já gravados no JSON local entre execuções do app.
extension Patient {
    enum CodingKeys: String, CodingKey {
        case id, criadoEm, atualizadoEm
        case nome, idade, sexo, pesoKg, alturaCm
        case comorbidades, usouAntibioticos30Dias, antibioticosRecentes, colonizacaoMDR
        case alergias, alergiasClasses, localAquisicao
        case creatininaSerica, clearanceEstimado, bilirrubinas, transaminases, lactato
        case ambiente, classificacao, probabilidadeInfeccao
        case medicoesScores, eventos, protocoloItens, reconhecimentoSepse
    }

    init(from decoder: Decoder) throws {
        let c = try decoder.container(keyedBy: CodingKeys.self)
        let def = Patient()

        self.init()
        self.id = try c.decodeIfPresent(UUID.self, forKey: .id) ?? def.id
        self.criadoEm = try c.decodeIfPresent(Date.self, forKey: .criadoEm) ?? def.criadoEm
        self.atualizadoEm = try c.decodeIfPresent(Date.self, forKey: .atualizadoEm) ?? def.atualizadoEm

        self.nome = try c.decodeIfPresent(String.self, forKey: .nome) ?? def.nome
        self.idade = try c.decodeIfPresent(Int.self, forKey: .idade) ?? def.idade
        self.sexo = try c.decodeIfPresent(Sexo.self, forKey: .sexo) ?? def.sexo
        self.pesoKg = try c.decodeIfPresent(Double.self, forKey: .pesoKg) ?? def.pesoKg
        self.alturaCm = try c.decodeIfPresent(Double.self, forKey: .alturaCm) ?? def.alturaCm

        self.comorbidades = try c.decodeIfPresent(Set<Comorbidade>.self, forKey: .comorbidades) ?? def.comorbidades
        self.usouAntibioticos30Dias = try c.decodeIfPresent(Bool.self, forKey: .usouAntibioticos30Dias) ?? def.usouAntibioticos30Dias
        self.antibioticosRecentes = try c.decodeIfPresent(String.self, forKey: .antibioticosRecentes) ?? def.antibioticosRecentes
        self.colonizacaoMDR = try c.decodeIfPresent(Set<OrganismoMDR>.self, forKey: .colonizacaoMDR) ?? def.colonizacaoMDR

        self.alergias = try c.decodeIfPresent(String.self, forKey: .alergias) ?? def.alergias
        self.alergiasClasses = try c.decodeIfPresent(Set<ClasseAntibiotico>.self, forKey: .alergiasClasses) ?? def.alergiasClasses
        self.localAquisicao = try c.decodeIfPresent(LocalAquisicao.self, forKey: .localAquisicao) ?? def.localAquisicao

        self.creatininaSerica = try c.decodeIfPresent(Double.self, forKey: .creatininaSerica) ?? def.creatininaSerica
        self.clearanceEstimado = try c.decodeIfPresent(Double.self, forKey: .clearanceEstimado) ?? def.clearanceEstimado
        self.bilirrubinas = try c.decodeIfPresent(Double.self, forKey: .bilirrubinas) ?? def.bilirrubinas
        self.transaminases = try c.decodeIfPresent(String.self, forKey: .transaminases) ?? def.transaminases
        self.lactato = try c.decodeIfPresent(Double.self, forKey: .lactato) ?? def.lactato

        self.ambiente = try c.decodeIfPresent(AmbienteAtendimento.self, forKey: .ambiente) ?? def.ambiente
        self.classificacao = try c.decodeIfPresent(ClassificacaoClinica.self, forKey: .classificacao) ?? def.classificacao
        self.probabilidadeInfeccao = try c.decodeIfPresent(ProbabilidadeInfeccao.self, forKey: .probabilidadeInfeccao) ?? def.probabilidadeInfeccao

        self.medicoesScores = try c.decodeIfPresent([ScoreMeasurement].self, forKey: .medicoesScores) ?? def.medicoesScores
        self.eventos = try c.decodeIfPresent([TimelineEvent].self, forKey: .eventos) ?? def.eventos
        self.protocoloItens = try c.decodeIfPresent([BundleItem].self, forKey: .protocoloItens) ?? def.protocoloItens
        self.reconhecimentoSepse = try c.decodeIfPresent(Date.self, forKey: .reconhecimentoSepse) ?? def.reconhecimentoSepse
    }
}
