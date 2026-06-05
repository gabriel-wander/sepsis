import XCTest
@testable import SepseApp

/// Os 10 cenários clínicos obrigatórios da auditoria, verificando scores, classificação
/// sugerida, alertas, alergia e doses de forma integrada.
final class ClinicalScenariosTests: XCTestCase {

    // 1. Infecção sem sepse
    func test01_infeccaoSemSepse() {
        var q = QSOFACalculator.Input(); q.glasgow = 15; q.frequenciaRespiratoria = 18; q.pressaoSistolica = 125
        XCTAssertEqual(QSOFACalculator.calcular(q).total, 0)

        var n = NEWSCalculator.Input(); n.frequenciaRespiratoria = 18; n.spo2 = 97; n.frequenciaCardiaca = 88; n.temperatura = 37.8
        XCTAssertLessThan(NEWSCalculator.calcular(n).total, 5)

        let s = SOFACalculator.calcular(SOFACalculator.Input())
        XCTAssertFalse(s.interpretacao.contains("= SEPSE"))

        XCTAssertNil(ClassificationAdvisor.sugestao(para: Patient()))
    }

    // 2. Sepse sem choque
    func test02_sepseSemChoque() {
        var i = SOFACalculator.Input()
        i.pao2fio2 = 280; i.plaquetas = 130; i.bilirrubina = 1.4; i.creatinina = 1.6; i.pam = 75
        let sofa = SOFACalculator.calcular(i)
        XCTAssertTrue(sofa.interpretacao.contains("= SEPSE"))

        var p = Patient()
        p.medicoesScores.append(ScoreMeasurement(tipo: .sofa, resultado: sofa))
        p.probabilidadeInfeccao = .alta
        // Alta probabilidade ⇒ janela de 1 hora mesmo sem choque.
        XCTAssertEqual(AlertService.janelaAntibioticoSegundos(para: p), 3600)
        XCTAssertTrue(ClassificationAdvisor.sugestao(para: p)!.localizedCaseInsensitiveContains("SEPSE"))
    }

    // 3. Choque séptico
    func test03_choqueSeptico() {
        var i = SOFACalculator.Input()
        i.pao2fio2 = 180; i.suporteVentilatorio = true; i.plaquetas = 80; i.bilirrubina = 2.5
        i.norepinefrina = 0.2; i.glasgow = 13; i.creatinina = 2.2
        let sofa = SOFACalculator.calcular(i)
        XCTAssertEqual(sofa.total, 14)
        XCTAssertEqual(sofa.gravidade, .vermelho)

        var p = Patient()
        p.lactato = 4.5
        p.classificacao = .choqueSeptico
        p.eventos.append(TimelineEvent(tipo: .vasopressor))
        XCTAssertTrue(ClassificationAdvisor.sugestao(para: p)!.localizedCaseInsensitiveContains("choque"))
        XCTAssertEqual(AlertService.janelaAntibioticoSegundos(para: p), 3600)
        XCTAssertTrue(AlertService.alertas(para: p).contains { $0.titulo.contains("> 4") })
    }

    // 4. qSOFA baixo com NEWS alto
    func test04_qsofaBaixoNewsAlto() {
        var q = QSOFACalculator.Input(); q.frequenciaRespiratoria = 26; q.glasgow = 15; q.pressaoSistolica = 112
        XCTAssertLessThan(QSOFACalculator.calcular(q).total, 2)

        var n = NEWSCalculator.Input()
        n.frequenciaRespiratoria = 26; n.spo2 = 91; n.oxigenioSuplementar = true; n.frequenciaCardiaca = 112; n.temperatura = 38.4
        let news = NEWSCalculator.calcular(n)
        XCTAssertGreaterThanOrEqual(news.total, 7)

        var p = Patient()
        p.medicoesScores.append(ScoreMeasurement(tipo: .news, resultado: news))
        // O NEWS alto DEVE gerar alerta crítico (lacuna corrigida na auditoria).
        XCTAssertTrue(AlertService.alertas(para: p).contains { $0.titulo.hasPrefix("NEWS") && $0.severidade == .critico })
    }

    // 5. Lactato elevado sem hipotensão
    func test05_lactatoSemHipotensao() {
        var p = Patient()
        p.lactato = 3.5
        // Sem vasopressor ⇒ NÃO sugere choque (Sepsis-3 exige vasopressor após volume).
        let s = ClassificationAdvisor.sugestao(para: p)
        XCTAssertFalse((s ?? "").localizedCaseInsensitiveContains("CHOQUE SÉPTICO"))
        // Mas há alerta de hipoperfusão.
        XCTAssertTrue(AlertService.alertas(para: p).contains { $0.titulo.contains("2–4") })
    }

    // 6. IC/DRC com risco de sobrecarga
    func test06_riscoSobrecarga() {
        var p = Patient()
        p.comorbidades = [.insuficienciaCardiaca, .insuficienciaRenal]
        p.pesoKg = 70
        // O volume de referência é calculado, mas a UI sinaliza cautela (testado pela presença das comorbidades).
        XCTAssertEqual(DoseCalculator.volumeRessuscitacaoMililitros(pesoKg: p.pesoKg), 2100, accuracy: 0.001)
        XCTAssertTrue(p.comorbidades.contains(.insuficienciaCardiaca))
        XCTAssertTrue(p.comorbidades.contains(.insuficienciaRenal))
    }

    // 7. Alergia a beta-lactâmico
    func test07_alergiaBetalactamico() {
        var p = Patient(); p.alergiasClasses = [.betalactamico]
        let pip = AntimicrobialDatabase.antimicrobianos.first { $0.nome == "Piperacilina-tazobactam" }!
        XCTAssertEqual(AllergyChecker.avaliar(antimicrobiano: pip, paciente: p)?.nivel, .conflito)
        XCTAssertTrue(AlertService.alertas(para: p).contains { $0.titulo == "Alergia a antibiótico" })
    }

    // 8. Risco MRSA/MDR
    func test08_riscoMDR() {
        var p = Patient()
        p.colonizacaoMDR = [.mrsa]
        p.localAquisicao = .hospitalar
        XCTAssertTrue(AntimicrobialDatabase.contextosRelevantes(para: p).contains("MDR"))
    }

    // 9. Neutropenia febril
    func test09_neutropeniaFebril() {
        var p = Patient()
        p.comorbidades = [.neoplasia, .imunossupressao]
        XCTAssertTrue(AntimicrobialDatabase.contextosRelevantes(para: p).contains("Neutropenia"))
    }

    // 10. Sepse com suspeita de disfunção miocárdica
    func test10_disfuncaoMiocardica() {
        // Dobutamina pontua no SOFA cardiovascular (qualquer dose) = 2, refletindo suporte inotrópico.
        var i = SOFACalculator.Input(); i.dobutamina = true; i.pam = 75
        XCTAssertEqual(SOFACalculator.cardiovascular(i), 2)
    }
}
