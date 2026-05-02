import XCTest

final class AtlasUITests: XCTestCase {

    var app: XCUIApplication!

    override func setUp() {
        super.setUp()
        continueAfterFailure = true
        app = XCUIApplication()
        app.launchArguments += ["--UITesting"]
        app.launch()
        sleep(2)
    }

    override func tearDown() {
        app = nil
        super.tearDown()
    }

    // MARK: - Helpers

    private func snap(_ name: String) {
        let sc = XCUIScreen.main.screenshot()
        let att = XCTAttachment(screenshot: sc)
        att.name = name
        att.lifetime = .keepAlways
        add(att)
    }

    private func setTimePicker(hour12: String, minute: String, ampm: String) {
        let timePicker = app.datePickers["timePicker"]
        guard timePicker.waitForExistence(timeout: 2) else { return }
        timePicker.tap()
        sleep(1)

        let wheels = app.pickerWheels.allElementsBoundByIndex
        if wheels.count >= 3 {
            // 12-hour format (H, MM, AM/PM)
            wheels[0].adjust(toPickerWheelValue: hour12)
            sleep(0.2)
            wheels[1].adjust(toPickerWheelValue: minute)
            sleep(0.2)
            wheels[2].adjust(toPickerWheelValue: ampm)
            sleep(0.2)
        } else if wheels.count == 2 {
            // 24-hour format
            let hour24 = ampm == "PM" ? String(Int(hour12)! + 12) : hour12
            wheels[0].adjust(toPickerWheelValue: hour24)
            sleep(0.2)
            wheels[1].adjust(toPickerWheelValue: minute)
            sleep(0.2)
        }

        // Dismiss the inline picker
        if app.buttons["Done"].exists {
            app.buttons["Done"].tap()
        } else {
            // Tap the section header above to dismiss
            app.staticTexts["Tags"].firstMatch.tap()
        }
        sleep(0.5)
    }

    // MARK: - Full journey

    func test_fullJourney() {

        // ── 1. All four tabs in empty state ──────────────────────────────

        snap("01-calendar-tab-empty")

        app.tabBars.buttons["Chat"].tap()
        sleep(1)
        snap("02-chat-tab-empty")

        app.tabBars.buttons["Income"].tap()
        sleep(1)
        snap("03-income-tab-empty")

        app.tabBars.buttons["Settings"].tap()
        sleep(1)
        snap("04-settings-tab")

        // ── 2. Open "Add Event" form ─────────────────────────────────────

        app.tabBars.buttons["Calendar"].tap()
        sleep(0.5)

        app.buttons["Add Event"].tap()
        sleep(1)
        snap("05-add-event-form-default")

        // ── 3. Navigate to Work → Basketball ─────────────────────────────

        app.segmentedControls["categoryPicker"].buttons["Work"].tap()
        sleep(0.5)

        // Basketball is the first option — tap explicitly to be safe
        let workPicker = app.segmentedControls["workTypePicker"]
        if workPicker.waitForExistence(timeout: 2) {
            workPicker.buttons["Basketball"].tap()
            sleep(0.3)
        }

        // ── 4. Set time to 18:45 (6:45 PM) ──────────────────────────────

        setTimePicker(hour12: "6", minute: "45", ampm: "PM")

        // ── 5. Enable Ropero and Postres tags ────────────────────────────
        // Scroll down so tags section is visible
        app.swipeUp()
        sleep(0.3)

        let ropero = app.switches["Ropero"]
        if ropero.waitForExistence(timeout: 2) {
            ropero.tap()
            sleep(0.2)
        }

        let postres = app.switches["Postres"]
        if postres.waitForExistence(timeout: 2) {
            postres.tap()
            sleep(0.2)
        }

        snap("06-add-form-tags-visible")

        // Scroll back up so the time and type are in frame too
        app.swipeDown()
        sleep(0.3)
        snap("07-add-form-basketball-complete")

        // ── 6. Confirm — add the event ───────────────────────────────────

        app.buttons["Add"].tap()
        sleep(1)
        snap("08-calendar-with-basketball-event")

        // ── 7. Income — basketball entry should show earnings ────────────

        app.tabBars.buttons["Income"].tap()
        sleep(1)
        snap("09-income-with-basketball-entry")

        // ── 8. Chat — type and send a message ────────────────────────────

        app.tabBars.buttons["Chat"].tap()
        sleep(1)

        // TextField(axis: .vertical) may surface as textField or textView
        var inputField: XCUIElement = app.textFields["messageInput"]
        if !inputField.waitForExistence(timeout: 2) {
            inputField = app.textViews["messageInput"]
        }
        if !inputField.exists {
            inputField = app.textViews.firstMatch
        }

        inputField.tap()
        sleep(0.5)
        inputField.typeText("What events do I have this week?")
        sleep(0.3)
        snap("10-chat-message-typed")

        app.buttons["Send"].tap()
        sleep(4) // stub delay is 0.6 s + UI update
        snap("11-chat-with-response")

        // ── 9. Calendar — final view with event pill ─────────────────────

        app.tabBars.buttons["Calendar"].tap()
        sleep(0.5)
        snap("12-calendar-final")
    }
}
