import XCTest
@testable import SepseApp

/// Testes de persistência/decodificação resiliente do Patient.
final class PatientCodableTests: XCTestCase {

    private func makeEncoder() -> JSONEncoder {
        let e = JSONEncoder(); e.dateEncodingStrategy = .iso8601; return e
    }
    private func makeDecoder() -> JSONDecoder {
        let d = JSONDecoder(); d.dateDecodingStrategy = .iso8601; return d
    }

    func testRoundTrip() throws {
        var p = Patient()
        p.nome = "Maria Teste"
        p.idade = 67
        p.pesoKg = 80
        p.comorbidades = [.diabetes, .insuficienciaRenal]
        p.alergiasClasses = [.penicilina]
        p.lactato = 3.2
        p.classificacao = .sepse
        p.probabilidadeInfeccao = .alta
        p.medicoesScores = [ScoreMeasurement(tipo: .qsofa, resultado: QSOFACalculator.calcular(QSOFACalculator.Input()))]

        let data = try makeEncoder().encode(p)
        let back = try makeDecoder().decode(Patient.self, from: data)

        XCTAssertEqual(back.id, p.id)
        XCTAssertEqual(back.nome, "Maria Teste")
        XCTAssertEqual(back.idade, 67)
        XCTAssertEqual(back.comorbidades, p.comorbidades)
        XCTAssertEqual(back.alergiasClasses, [.penicilina])
        XCTAssertEqual(back.lactato, 3.2)
        XCTAssertEqual(back.classificacao, .sepse)
        XCTAssertEqual(back.probabilidadeInfeccao, .alta)
        XCTAssertEqual(back.medicoesScores.count, 1)
    }

    /// JSON antigo (sem os campos novos) deve decodificar com defaults, sem lançar erro.
    func testDecodeJSONMinimoNaoLanca() throws {
        let json = """
        { "nome": "Paciente Legado", "idade": 50 }
        """.data(using: .utf8)!

        let p = try makeDecoder().decode(Patient.self, from: json)
        XCTAssertEqual(p.nome, "Paciente Legado")
        XCTAssertEqual(p.idade, 50)
        // Defaults aplicados a campos ausentes:
        XCTAssertEqual(p.sexo, .masculino)
        XCTAssertEqual(p.ambiente, .prontoSocorro)
        XCTAssertEqual(p.classificacao, .indeterminado)
        XCTAssertEqual(p.probabilidadeInfeccao, .naoAvaliada)
        XCTAssertTrue(p.alergiasClasses.isEmpty)
        XCTAssertNil(p.lactato)
        XCTAssertTrue(p.medicoesScores.isEmpty)
        XCTAssertTrue(p.eventos.isEmpty)
    }

    /// Decodificar uma lista (como o DataStore faz) também deve funcionar.
    func testDecodeArrayMisto() throws {
        let json = """
        [ { "nome": "A" }, { "nome": "B", "lactato": 4.1 } ]
        """.data(using: .utf8)!
        let lista = try makeDecoder().decode([Patient].self, from: json)
        XCTAssertEqual(lista.count, 2)
        XCTAssertEqual(lista[0].nome, "A")
        XCTAssertEqual(lista[1].lactato, 4.1)
    }
}
