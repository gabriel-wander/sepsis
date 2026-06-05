import XCTest

/// Testes de UI (XCUITest) do fluxo mínimo navegável.
/// São testes black-box: não importam o módulo do app, apenas dirigem a interface.
final class SepseAppUITests: XCTestCase {

    override func setUpWithError() throws {
        continueAfterFailure = false
    }

    /// Smoke test: o app lança e mostra a lista de pacientes.
    func testAppLancaEMostraLista() {
        let app = XCUIApplication()
        app.launch()
        XCTAssertTrue(app.navigationBars["Pacientes"].waitForExistence(timeout: 20),
                      "A tela inicial 'Pacientes' deveria aparecer.")
    }

    /// Fluxo: criar um paciente e vê-lo aparecer na lista.
    func testCriarPacienteApareceNaLista() {
        let app = XCUIApplication()
        app.launch()

        let addButton = app.buttons["addPatient"]
        XCTAssertTrue(addButton.waitForExistence(timeout: 20))
        addButton.tap()

        let nameField = app.textFields["patientName"]
        XCTAssertTrue(nameField.waitForExistence(timeout: 20))
        nameField.tap()
        nameField.typeText("Paciente UITest")

        let saveButton = app.buttons["savePatient"]
        XCTAssertTrue(saveButton.waitForExistence(timeout: 10))
        saveButton.tap()

        // Após salvar, a lista deixa de estar vazia (a célula do paciente aparece).
        XCTAssertTrue(app.cells.firstMatch.waitForExistence(timeout: 20),
                      "Uma célula de paciente deveria aparecer na lista após salvar.")
    }
}
