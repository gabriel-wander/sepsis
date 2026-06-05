import XCTest
@testable import SepseApp

/// Testes de modelo e de critérios adicionais (lógica pura).
final class CoreModelTests: XCTestCase {

    // MARK: - Patient (cálculos)

    func testCockcroftGault() {
        var p = Patient()
        p.idade = 60; p.pesoKg = 72; p.creatininaSerica = 1.0; p.sexo = .masculino
        // (140-60)*72 / (72*1) = 80
        XCTAssertEqual(p.clearanceCalculado ?? -1, 80, accuracy: 0.01)
        p.sexo = .feminino
        XCTAssertEqual(p.clearanceCalculado ?? -1, 68, accuracy: 0.01) // 80 * 0.85
    }

    func testClearanceManualTemPrecedencia() {
        var p = Patient()
        p.creatininaSerica = 1.0; p.idade = 60; p.pesoKg = 72
        p.clearanceEstimado = 45
        XCTAssertEqual(p.clearanceCalculado, 45)
    }

    func testIMC() {
        var p = Patient(); p.pesoKg = 80; p.alturaCm = 200
        XCTAssertEqual(p.imc ?? -1, 20, accuracy: 0.001)
    }

    func testGravidadeUsaUltimaMedicaoDeTriagem() {
        var p = Patient(); p.ambiente = .enfermaria   // triagem recomendada = NEWS
        var i = NEWSCalculator.Input(); i.frequenciaRespiratoria = 26; i.spo2 = 91; i.oxigenioSuplementar = true
        p.medicoesScores.append(ScoreMeasurement(tipo: .news, resultado: NEWSCalculator.calcular(i)))
        XCTAssertEqual(p.gravidade, .vermelho)
    }

    // MARK: - Critérios adicionais

    func testSIRS_PaCO2() {
        var i = SIRSCalculator.Input(); i.paco2 = 30   // < 32 → 1 critério respiratório
        XCTAssertEqual(SIRSCalculator.calcular(i).total, 1)
    }

    func testQSOFA_PASLimite100() {
        var i = QSOFACalculator.Input(); i.pressaoSistolica = 100  // ≤ 100 → 1
        XCTAssertEqual(QSOFACalculator.calcular(i).total, 1)
    }

    func testNEWS_oxigenioSuplementar() {
        var i = NEWSCalculator.Input(); i.oxigenioSuplementar = true
        XCTAssertEqual(NEWSCalculator.calcular(i).total, 2)
    }

    func testAPACHEII_phLimites() {
        var i = APACHEIICalculator.Input()
        i.ph = 7.49; XCTAssertEqual(APACHEIICalculator.pPH(i.ph), 0)
        i.ph = 7.50; XCTAssertEqual(APACHEIICalculator.pPH(i.ph), 1)
    }

    func testAPACHEII_tempLimites() {
        XCTAssertEqual(APACHEIICalculator.pTemp(38.5), 1)
        XCTAssertEqual(APACHEIICalculator.pTemp(38.4), 0)
    }

    // MARK: - Dados

    func testContagensDeDados() {
        XCTAssertEqual(AntimicrobialDatabase.antimicrobianos.count, 8)
        XCTAssertEqual(AntimicrobialDatabase.defaultRegimes().count, 5)
        XCTAssertEqual(BundleItem.padrao().count, 9)
        XCTAssertEqual(ProtocolData.fluxogramas.count, 5)
    }
}
