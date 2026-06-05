import XCTest
@testable import SepseApp

/// Testes dos calculadores de scores. Valores esperados derivados das tabelas clínicas
/// implementadas (Sepsis-3, SSC 2021, RCP NEWS, Knaus APACHE II).
final class ScoreCalculatorsTests: XCTestCase {

    // MARK: - qSOFA

    func testQSOFA_normal() {
        let r = QSOFACalculator.calcular(QSOFACalculator.Input())
        XCTAssertEqual(r.total, 0)
        XCTAssertEqual(r.gravidade, .verde)
    }

    func testQSOFA_maximo() {
        var i = QSOFACalculator.Input()
        i.glasgow = 14; i.frequenciaRespiratoria = 24; i.pressaoSistolica = 90
        let r = QSOFACalculator.calcular(i)
        XCTAssertEqual(r.total, 3)
        XCTAssertEqual(r.gravidade, .vermelho)
        XCTAssertTrue(r.interpretacao.localizedCaseInsensitiveContains("não exclui sepse"))
    }

    func testQSOFA_umPonto() {
        var i = QSOFACalculator.Input()
        i.frequenciaRespiratoria = 22
        let r = QSOFACalculator.calcular(i)
        XCTAssertEqual(r.total, 1)
        XCTAssertEqual(r.gravidade, .amarelo)
    }

    // MARK: - SOFA

    func testSOFA_componentesRespiratorio() {
        func resp(_ pf: Double, vent: Bool) -> Int {
            var i = SOFACalculator.Input(); i.pao2fio2 = pf; i.suporteVentilatorio = vent
            return SOFACalculator.respiratorio(i)
        }
        XCTAssertEqual(resp(450, vent: false), 0)
        XCTAssertEqual(resp(350, vent: false), 1)
        XCTAssertEqual(resp(250, vent: false), 2)
        XCTAssertEqual(resp(180, vent: true), 3)
        XCTAssertEqual(resp(90, vent: true), 4)
        XCTAssertEqual(resp(180, vent: false), 2) // <200 sem suporte cai para faixa <300
    }

    func testSOFA_cardiovascular() {
        func cv(_ f: (inout SOFACalculator.Input) -> Void) -> Int {
            var i = SOFACalculator.Input(); f(&i); return SOFACalculator.cardiovascular(i)
        }
        XCTAssertEqual(cv { $0.pam = 80 }, 0)
        XCTAssertEqual(cv { $0.pam = 65 }, 1)
        XCTAssertEqual(cv { $0.dobutamina = true }, 2)
        XCTAssertEqual(cv { $0.dopamina = 3 }, 2)
        XCTAssertEqual(cv { $0.norepinefrina = 0.05 }, 3)
        XCTAssertEqual(cv { $0.norepinefrina = 0.2 }, 4)
        XCTAssertEqual(cv { $0.dopamina = 20 }, 4)
    }

    func testSOFA_sepse_deltaMaiorIgual2() {
        var i = SOFACalculator.Input()
        i.pao2fio2 = 280   // 2
        i.plaquetas = 130  // 1
        i.bilirrubina = 1.4 // 1
        i.creatinina = 1.6  // 1
        i.sofaBasal = 0
        let r = SOFACalculator.calcular(i)
        XCTAssertEqual(r.total, 5)
        XCTAssertTrue(r.interpretacao.contains("= SEPSE"))
        XCTAssertEqual(r.gravidade, .amarelo) // <8
    }

    func testSOFA_naoSepse_quandoDeltaMenor2() {
        var i = SOFACalculator.Input()
        i.creatinina = 1.6 // total 1
        i.sofaBasal = 0
        let r = SOFACalculator.calcular(i)
        XCTAssertEqual(r.total, 1)
        XCTAssertFalse(r.interpretacao.contains("= SEPSE"))
    }

    // MARK: - SIRS

    func testSIRS_temperaturaThreshold38() {
        var i = SIRSCalculator.Input()
        i.temperatura = 38.0
        XCTAssertEqual(SIRSCalculator.calcular(i).total, 0, "38,0 não deve pontuar (critério é > 38,0)")
        i.temperatura = 38.1
        XCTAssertEqual(SIRSCalculator.calcular(i).total, 1)
    }

    func testSIRS_quatroCriterios() {
        var i = SIRSCalculator.Input()
        i.temperatura = 38.5; i.frequenciaCardiaca = 95; i.frequenciaRespiratoria = 22; i.leucocitos = 15000
        let r = SIRSCalculator.calcular(i)
        XCTAssertEqual(r.total, 4)
        XCTAssertEqual(r.gravidade, .amarelo)
    }

    // MARK: - NEWS

    func testNEWS_normal() {
        XCTAssertEqual(NEWSCalculator.calcular(NEWSCalculator.Input()).total, 0)
    }

    func testNEWS_qSOFABaixoNEWSAlto() {
        var i = NEWSCalculator.Input()
        i.frequenciaRespiratoria = 26 // 3
        i.spo2 = 91                   // 3
        i.oxigenioSuplementar = true  // 2
        i.temperatura = 38.4          // 1
        i.pressaoSistolica = 112      // 0
        i.frequenciaCardiaca = 112    // 2
        let r = NEWSCalculator.calcular(i)
        XCTAssertEqual(r.total, 11)
        XCTAssertEqual(r.gravidade, .vermelho)
    }

    func testNEWS_faixaIntermediaria() {
        var i = NEWSCalculator.Input()
        i.frequenciaRespiratoria = 21 // 2
        i.spo2 = 94                   // 1
        i.temperatura = 35.5          // 1
        i.frequenciaCardiaca = 50     // 1
        let r = NEWSCalculator.calcular(i)
        XCTAssertEqual(r.total, 5)
        XCTAssertEqual(r.gravidade, .amarelo)
    }

    // MARK: - APACHE II

    func testAPACHEII_default() {
        // Idade 50 => 2 pontos; demais 0.
        let r = APACHEIICalculator.calcular(APACHEIICalculator.Input())
        XCTAssertEqual(r.total, 2)
        XCTAssertEqual(r.gravidade, .verde)
    }

    func testAPACHEII_creatininaDobraComIRA() {
        var i = APACHEIICalculator.Input()
        i.creatinina = 2.5
        XCTAssertEqual(APACHEIICalculator.pCreatinina(i), 3)
        i.insuficienciaRenalAguda = true
        XCTAssertEqual(APACHEIICalculator.pCreatinina(i), 6)
    }

    func testAPACHEII_casoGrave() {
        var i = APACHEIICalculator.Input()
        i.idade = 70                 // 5
        i.temperatura = 39.5         // 3
        i.pam = 60                   // 2
        i.frequenciaCardiaca = 130   // 2
        i.frequenciaRespiratoria = 36 // 3
        i.fio2 = 0.6; i.aadO2 = 400  // 3
        i.ph = 7.2                   // 3
        i.sodio = 150                // 1
        i.potassio = 5.6             // 1
        i.creatinina = 2.5; i.insuficienciaRenalAguda = true // 6
        i.hematocrito = 28           // 2
        i.leucocitos = 22            // 2
        i.glasgow = 10               // 5
        i.condicaoCronica = .naoOperatorioOuEmergencia // 5
        let r = APACHEIICalculator.calcular(i)
        XCTAssertEqual(r.total, 43)
        XCTAssertEqual(r.gravidade, .vermelho)
    }

    // MARK: - MEDS

    func testMEDS_zero() {
        let r = MEDSCalculator.calcular(MEDSCalculator.Input())
        XCTAssertEqual(r.total, 0)
        XCTAssertEqual(r.gravidade, .verde)
    }

    func testMEDS_moderado() {
        var i = MEDSCalculator.Input()
        i.idadeMaior65 = true; i.choqueSeptico = true; i.plaquetasBaixas = true
        let r = MEDSCalculator.calcular(i)
        XCTAssertEqual(r.total, 9)
    }

    func testMEDS_maximo() {
        var i = MEDSCalculator.Input()
        i.idadeMaior65 = true; i.bandasMaior5 = true; i.taquipneia = true
        i.choqueSeptico = true; i.plaquetasBaixas = true; i.lactatoElevado = true
        i.alteracaoEstadoMental = true; i.infeccaoHospitalar = true; i.residenciaILPI = true
        let r = MEDSCalculator.calcular(i)
        XCTAssertEqual(r.total, 24)
        XCTAssertEqual(r.gravidade, .vermelho)
    }
}
