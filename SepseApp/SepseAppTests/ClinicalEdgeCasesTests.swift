import XCTest
@testable import SepseApp

/// Casos de borda dos calculadores e serviços, complementando os testes principais.
final class ClinicalEdgeCasesTests: XCTestCase {

    // MARK: - SOFA: limites e débito urinário

    func testSOFA_respiratorioLimite400() {
        var i = SOFACalculator.Input(); i.pao2fio2 = 400
        XCTAssertEqual(SOFACalculator.respiratorio(i), 0)
        i.pao2fio2 = 399
        XCTAssertEqual(SOFACalculator.respiratorio(i), 1)
    }

    func testSOFA_renalPorDebitoUrinario() {
        var i = SOFACalculator.Input(); i.creatinina = 1.0
        i.debitoUrinario = 150           // < 200 → 4 (sobrepõe creatinina normal)
        XCTAssertEqual(SOFACalculator.renal(i), 4)
        i.debitoUrinario = 400           // < 500 → 3
        XCTAssertEqual(SOFACalculator.renal(i), 3)
        i.debitoUrinario = 600           // sem critério de débito → usa creatinina (1.0 → 0)
        XCTAssertEqual(SOFACalculator.renal(i), 0)
    }

    func testSOFA_neurologicoFaixas() {
        func neuro(_ g: Int) -> Int { var i = SOFACalculator.Input(); i.glasgow = g; return SOFACalculator.neurologico(i) }
        XCTAssertEqual(neuro(15), 0)
        XCTAssertEqual(neuro(14), 1)
        XCTAssertEqual(neuro(12), 2)
        XCTAssertEqual(neuro(9), 3)
        XCTAssertEqual(neuro(5), 4)
    }

    // MARK: - NEWS: limites

    func testNEWS_limitesSpO2EPAS() {
        XCTAssertEqual(NEWSCalculator.pontosSpO2(92), 2)
        XCTAssertEqual(NEWSCalculator.pontosSpO2(91), 3)
        XCTAssertEqual(NEWSCalculator.pontosPAS(91), 2)
        XCTAssertEqual(NEWSCalculator.pontosPAS(90), 3)
        XCTAssertEqual(NEWSCalculator.pontosPAS(219), 0)
        XCTAssertEqual(NEWSCalculator.pontosPAS(220), 3)
    }

    // MARK: - APACHE II: oxigenação por FiO2

    func testAPACHEII_oxigenacaoFiO2Alta() {
        var i = APACHEIICalculator.Input(); i.fio2 = 0.6
        i.aadO2 = 100; XCTAssertEqual(APACHEIICalculator.pOxigenacao(i), 0)
        i.aadO2 = 200; XCTAssertEqual(APACHEIICalculator.pOxigenacao(i), 2)
        i.aadO2 = 350; XCTAssertEqual(APACHEIICalculator.pOxigenacao(i), 3)
        i.aadO2 = 500; XCTAssertEqual(APACHEIICalculator.pOxigenacao(i), 4)
    }

    func testAPACHEII_oxigenacaoFiO2Baixa() {
        var i = APACHEIICalculator.Input(); i.fio2 = 0.4
        i.pao2 = 80; XCTAssertEqual(APACHEIICalculator.pOxigenacao(i), 0)
        i.pao2 = 65; XCTAssertEqual(APACHEIICalculator.pOxigenacao(i), 1)
        i.pao2 = 58; XCTAssertEqual(APACHEIICalculator.pOxigenacao(i), 3)
        i.pao2 = 50; XCTAssertEqual(APACHEIICalculator.pOxigenacao(i), 4)
    }

    // MARK: - MEDS: bandas de risco

    func testMEDS_bandasDeRisco() {
        var i = MEDSCalculator.Input()
        i.idadeMaior65 = true; i.alteracaoEstadoMental = true   // 3 + 2 = 5
        XCTAssertEqual(MEDSCalculator.calcular(i).gravidade, .amarelo)

        i.choqueSeptico = true                                  // + 3 = 8 (moderado)
        let r = MEDSCalculator.calcular(i)
        XCTAssertEqual(r.total, 8)
        XCTAssertEqual(r.gravidade, .amarelo)
    }

    // MARK: - AllergyChecker

    func testAllergy_nitroimidazol() {
        var p = Patient(); p.alergiasClasses = [.nitroimidazol]
        let metro = AntimicrobialDatabase.antimicrobianos.first { $0.nome == "Metronidazol" }!
        XCTAssertEqual(AllergyChecker.avaliar(antimicrobiano: metro, paciente: p)?.nivel, .conflito)
    }

    func testAllergy_regimeSemFarmacoConhecido() {
        var p = Patient(); p.alergiasClasses = [.penicilina]
        let reg = EmpiricRegimen(contexto: "Custom", regime: "Antibiótico institucional X 1g", exemplo: false)
        XCTAssertNil(AllergyChecker.avaliar(regime: reg, paciente: p))
    }

    // MARK: - DoseCalculator: limites de função renal

    func testFaixaRenalLimites() {
        XCTAssertEqual(DoseCalculator.faixaRenal(clearance: 50), .normal)
        XCTAssertEqual(DoseCalculator.faixaRenal(clearance: 49.9), .moderada)
        XCTAssertEqual(DoseCalculator.faixaRenal(clearance: 30), .moderada)
        XCTAssertEqual(DoseCalculator.faixaRenal(clearance: 29.9), .grave)
        XCTAssertEqual(DoseCalculator.faixaRenal(clearance: 10), .grave)
        XCTAssertEqual(DoseCalculator.faixaRenal(clearance: 9.9), .terminal)
    }
}
