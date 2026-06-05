import XCTest
@testable import SepseApp

/// Testes das camadas de apoio à decisão: ClassificationAdvisor, AlertService, AllergyChecker
/// e calculadoras de dose.
final class ServicesTests: XCTestCase {

    // MARK: - Helpers

    private func medicaoSOFA(total: Int, sepse: Bool) -> ScoreMeasurement {
        var input = SOFACalculator.Input()
        // Constrói um SOFA cujo texto contenha (ou não) o marcador "= SEPSE".
        if sepse {
            input.pao2fio2 = 280; input.plaquetas = 130; input.bilirrubina = 1.4; input.creatinina = 1.6
        }
        let r = SOFACalculator.calcular(input)
        return ScoreMeasurement(tipo: .sofa, resultado: r)
    }

    // MARK: - ClassificationAdvisor

    func testAdvisor_nilSemDados() {
        XCTAssertNil(ClassificationAdvisor.sugestao(para: Patient()))
    }

    func testAdvisor_choque_vasopressorMaisLactato() {
        var p = Patient()
        p.lactato = 3.0
        p.eventos.append(TimelineEvent(tipo: .vasopressor))
        let s = ClassificationAdvisor.sugestao(para: p)
        XCTAssertNotNil(s)
        XCTAssertTrue(s!.localizedCaseInsensitiveContains("choque"))
    }

    func testAdvisor_vasopressorSemLactatoElevado() {
        var p = Patient()
        p.lactato = 1.5
        p.eventos.append(TimelineEvent(tipo: .vasopressor))
        let s = ClassificationAdvisor.sugestao(para: p)
        XCTAssertNotNil(s)
        XCTAssertTrue(s!.localizedCaseInsensitiveContains("vasopressor"))
        XCTAssertFalse(s!.localizedCaseInsensitiveContains("CHOQUE SÉPTICO"))
    }

    func testAdvisor_sepsePorSOFA() {
        var p = Patient()
        p.medicoesScores.append(medicaoSOFA(total: 5, sepse: true))
        let s = ClassificationAdvisor.sugestao(para: p)
        XCTAssertNotNil(s)
        XCTAssertTrue(s!.localizedCaseInsensitiveContains("SEPSE"))
    }

    // MARK: - AlertService

    func testAlert_alergia() {
        var p = Patient()
        p.alergiasClasses = [.penicilina]
        let alertas = AlertService.alertas(para: p)
        XCTAssertTrue(alertas.contains { $0.titulo == "Alergia a antibiótico" })
    }

    func testAlert_NEWS() {
        var p = Patient()
        p.medicoesScores.append(ScoreMeasurement(tipo: .news, resultado: NEWSCalculator.calcular({
            var i = NEWSCalculator.Input(); i.frequenciaRespiratoria = 26; i.spo2 = 91
            i.oxigenioSuplementar = true; i.frequenciaCardiaca = 112; return i
        }())))
        let alertas = AlertService.alertas(para: p)
        XCTAssertTrue(alertas.contains { $0.titulo.hasPrefix("NEWS") && $0.severidade == .critico })
    }

    func testAlert_lactato() {
        var p = Patient(); p.lactato = 5.0
        XCTAssertTrue(AlertService.alertas(para: p).contains { $0.titulo.contains("> 4") && $0.severidade == .critico })
        p.lactato = 3.0
        XCTAssertTrue(AlertService.alertas(para: p).contains { $0.titulo.contains("2–4") && $0.severidade == .atencao })
    }

    func testJanelaAntibiotico() {
        var p = Patient()
        p.classificacao = .choqueSeptico
        XCTAssertEqual(AlertService.janelaAntibioticoSegundos(para: p), 3600)
        p.classificacao = .indeterminado
        p.probabilidadeInfeccao = .alta
        XCTAssertEqual(AlertService.janelaAntibioticoSegundos(para: p), 3600)
        p.probabilidadeInfeccao = .possivel
        XCTAssertEqual(AlertService.janelaAntibioticoSegundos(para: p), 10800)
        p.probabilidadeInfeccao = .baixa
        XCTAssertNil(AlertService.janelaAntibioticoSegundos(para: p))
    }

    func testAlert_antibioticoDentroEAtrasado() {
        var p = Patient()
        p.classificacao = .choqueSeptico
        let agora = Date()
        p.reconhecimentoSepse = agora
        let dentro = AlertService.alertas(para: p, agora: agora)
        XCTAssertTrue(dentro.contains { $0.titulo == "Administrar antibiótico" })

        let depois = AlertService.alertas(para: p, agora: agora.addingTimeInterval(2 * 3600))
        XCTAssertTrue(depois.contains { $0.titulo == "Antibiótico ATRASADO" && $0.severidade == .critico })
    }

    func testAlert_baixaProbabilidadeNaoForcaAntibiotico() {
        var p = Patient()
        p.probabilidadeInfeccao = .baixa
        p.reconhecimentoSepse = Date()
        let alertas = AlertService.alertas(para: p)
        XCTAssertTrue(alertas.contains { $0.titulo == "Reavaliar antes de antibiótico" })
        XCTAssertFalse(alertas.contains { $0.titulo == "Antibiótico ATRASADO" })
    }

    // MARK: - AllergyChecker

    func testAllergy_conflitoDireto() {
        var p = Patient(); p.alergiasClasses = [.betalactamico]
        let cef = AntimicrobialDatabase.antimicrobianos.first { $0.nome == "Ceftriaxona" }!
        let r = AllergyChecker.avaliar(antimicrobiano: cef, paciente: p)
        XCTAssertEqual(r?.nivel, .conflito)
    }

    func testAllergy_reatividadeCruzada() {
        var p = Patient(); p.alergiasClasses = [.penicilina]
        let cef = AntimicrobialDatabase.antimicrobianos.first { $0.nome == "Ceftriaxona" }!
        let r = AllergyChecker.avaliar(antimicrobiano: cef, paciente: p)
        XCTAssertEqual(r?.nivel, .cautela)
    }

    func testAllergy_penicilinaConflitoComPipTazo() {
        var p = Patient(); p.alergiasClasses = [.penicilina]
        let pip = AntimicrobialDatabase.antimicrobianos.first { $0.nome == "Piperacilina-tazobactam" }!
        XCTAssertEqual(AllergyChecker.avaliar(antimicrobiano: pip, paciente: p)?.nivel, .conflito)
    }

    func testAllergy_semAlergiaRetornaNil() {
        let p = Patient()
        let cef = AntimicrobialDatabase.antimicrobianos.first { $0.nome == "Ceftriaxona" }!
        XCTAssertNil(AllergyChecker.avaliar(antimicrobiano: cef, paciente: p))
    }

    func testAllergy_regimeTextoLivre() {
        var p = Patient(); p.alergiasClasses = [.betalactamico]
        let reg = EmpiricRegimen(contexto: "PAC", regime: "Ceftriaxona 1g + Azitromicina 500mg", exemplo: false)
        XCTAssertEqual(AllergyChecker.avaliar(regime: reg, paciente: p)?.nivel, .conflito)
    }

    // MARK: - DoseCalculator

    func testFluidos30mlKg() {
        XCTAssertEqual(DoseCalculator.volumeRessuscitacaoMililitros(pesoKg: 70), 2100, accuracy: 0.001)
        XCTAssertEqual(DoseCalculator.volumeRessuscitacaoMililitros(pesoKg: 55), 1650, accuracy: 0.001)
    }

    func testVasopressorInfusao() {
        // 0,1 mcg/kg/min, 70 kg, 16 mcg/mL => 7 mcg/min => 420 mcg/h => 26,25 mL/h.
        let taxa = DoseCalculator.taxaInfusaoMlPorHora(doseMcgKgMin: 0.1, pesoKg: 70, concentracaoMcgPorMl: 16)
        XCTAssertEqual(taxa, 26.25, accuracy: 0.01)
        XCTAssertEqual(DoseCalculator.doseAbsolutaMcgMin(doseMcgKgMin: 0.1, pesoKg: 70), 7, accuracy: 0.001)
    }

    func testFaixaRenal() {
        XCTAssertEqual(DoseCalculator.faixaRenal(clearance: 60), .normal)
        XCTAssertEqual(DoseCalculator.faixaRenal(clearance: 40), .moderada)
        XCTAssertEqual(DoseCalculator.faixaRenal(clearance: 20), .grave)
        XCTAssertEqual(DoseCalculator.faixaRenal(clearance: 5), .terminal)
    }
}
