import XCTest

final class SquareupUITests: XCTestCase {
    override func setUpWithError() throws {
        continueAfterFailure = false
    }

    private func launchApp() -> XCUIApplication {
        let app = XCUIApplication()
        app.launchArguments = ["-uiTestReset"]
        app.launch()
        return app
    }

    func testLogPurchaseAddsRoundUpEntry() throws {
        let app = launchApp()

        let logButton = app.buttons["logPurchaseButton"]
        XCTAssertTrue(logButton.waitForExistence(timeout: 5))
        logButton.tap()

        let labelField = app.textFields["entryLabelField"]
        XCTAssertTrue(labelField.waitForExistence(timeout: 5))
        labelField.tap()
        labelField.typeText("Coffee")

        let amountField = app.textFields["entryAmountField"]
        amountField.tap()
        amountField.typeText("4.35")

        let saveButton = app.buttons["entrySaveButton"]
        XCTAssertTrue(saveButton.waitForExistence(timeout: 5))
        saveButton.tap()

        XCTAssertTrue(app.staticTexts["Coffee"].waitForExistence(timeout: 5), "New round-up entry did not appear")
    }

    func testShakeJarAddsEntryWithoutTyping() throws {
        let app = launchApp()

        let shakeButton = app.buttons["shakeJarButton"]
        XCTAssertTrue(shakeButton.waitForExistence(timeout: 5))
        shakeButton.tap()

        XCTAssertTrue(app.staticTexts["Shake toss"].waitForExistence(timeout: 5), "Shake quick-add did not create an entry")
    }

    func testAddJarHitsFreeLimitAndShowsPaywall() throws {
        let app = launchApp()

        let addJarButton = app.buttons["addJarButton"]
        XCTAssertTrue(addJarButton.waitForExistence(timeout: 5))
        addJarButton.tap()

        XCTAssertTrue(app.staticTexts["Squareup Pro"].waitForExistence(timeout: 5), "Paywall did not appear when exceeding the free jar limit")
    }

    func testKeyboardDismissesOnTapOutside() throws {
        let app = launchApp()

        app.buttons["logPurchaseButton"].tap()
        let labelField = app.textFields["entryLabelField"]
        XCTAssertTrue(labelField.waitForExistence(timeout: 5))
        labelField.tap()
        labelField.typeText("Test")
        XCTAssertTrue(app.keyboards.element.exists)

        // Tap a real Form section header, not the nav bar chrome.
        app.staticTexts["Spare Change"].tap()

        let keyboardGone = !app.keyboards.element.exists
        XCTAssertTrue(keyboardGone || !app.keyboards.element.isHittable, "Keyboard did not dismiss on tap outside")
    }

    func testSettingsTabShowsRestorePurchases() throws {
        let app = launchApp()
        app.tabBars.buttons["Settings"].tap()
        XCTAssertTrue(app.staticTexts["Restore Purchases"].waitForExistence(timeout: 5))
    }
}
