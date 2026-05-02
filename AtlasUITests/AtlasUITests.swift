import XCTest

final class AtlasUITests: XCTestCase {

    var app: XCUIApplication!

    // Screenshots written here; the workflow uploads this directory directly.
    private let screenshotDir = "/tmp/atlas-screenshots"

    override func setUp() {
        super.setUp()
        continueAfterFailure = true

        // Prepare screenshot output directory
        try? FileManager.default.createDirectory(
            atPath: screenshotDir,
            withIntermediateDirectories: true
        )

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

        // 1. XCTAttachment (stored in xcresult)
        let att = XCTAttachment(screenshot: sc)
        att.name = name
        att.lifetime = .keepAlways
        add(att)

        // 2. Write PNG directly to disk so the workflow can upload it
        //    even if xcresult parsing fails.
        let path = "\(screenshotDir)/\(name).png"
        try? sc.pngRepresentation.write(to: URL(fileURLWithPath: path))
    }

    // Safely tap a button by label — skips if not found within timeout.
    private func tap(_ label: String, timeout: TimeInterval = 3) {
        let btn = app.buttons[label]
        guard btn.waitForExistence(timeout: timeout) else { return }
        btn.tap()
    }

    private func pause(_ seconds: TimeInterval) {
        Thread.sleep(forTimeInterval: seconds)
    }

    private func setTimePicker(hour12: String, minute: String, ampm: String) {
        let timePicker = app.datePickers["timePicker"]
        guard timePicker.waitForExistence(timeout: 3) else { return }
        timePicker.tap()
        sleep(1)

        let wheels = app.pickerWheels.allElementsBoundByIndex
        if wheels.count >= 3 {
            // 12-hour (H, MM, AM/PM)
            wheels[0].adjust(toPickerWheelValue: hour12)
            pause(0.2)
            wheels[1].adjust(toPickerWheelValue: minute)
            pause(0.2)
            wheels[2].adjust(toPickerWheelValue: ampm)
            pause(0.2)
        } else if wheels.count == 2 {
            // 24-hour
            let h = Int(hour12)! + (ampm == "PM" ? 12 : 0)
            wheels[0].adjust(toPickerWheelValue: String(h))
            pause(0.2)
            wheels[1].adjust(toPickerWheelValue: minute)
            pause(0.2)
        }

        // Dismiss inline picker — try "Done", then tap a neutral spot
        if app.buttons["Done"].exists {
            app.buttons["Done"].tap()
        } else {
            app.coordinate(withNormalizedOffset: CGVector(dx: 0.5, dy: 0.15)).tap()
        }
        pause(0.5)
    }

    // MARK: - Full journey

    func test_fullJourney() {

        // ── 1. All four tabs — empty state ───────────────────────────────

        snap("01-calendar-tab-empty")

        app.tabBars.buttons["Chat"].tap(); sleep(1)
        snap("02-chat-tab-empty")

        app.tabBars.buttons["Income"].tap(); sleep(1)
        snap("03-income-tab-empty")

        app.tabBars.buttons["Settings"].tap(); sleep(1)
        snap("04-settings-tab")

        // ── 2. Open Add Event form ────────────────────────────────────────

        app.tabBars.buttons["Calendar"].tap(); pause(0.5)
        tap("Add Event")
        sleep(1)
        snap("05-add-event-form-open")

        // ── 3. Work → Basketball ──────────────────────────────────────────

        // Category picker: School | Work | Other
        let catPicker = app.segmentedControls["categoryPicker"]
        if catPicker.waitForExistence(timeout: 3) {
            catPicker.buttons["Work"].tap(); pause(0.5)
        }

        // Work type picker: Basketball | Football | Event
        let typePicker = app.segmentedControls["workTypePicker"]
        if typePicker.waitForExistence(timeout: 3) {
            typePicker.buttons["Basketball"].tap(); pause(0.3)
        }

        // ── 4. Time → 18:45 ──────────────────────────────────────────────

        setTimePicker(hour12: "6", minute: "45", ampm: "PM")

        // ── 5. Ropero + Postres tags ──────────────────────────────────────

        // Scroll down to reveal the Tags section
        app.swipeUp(); pause(0.4)

        let ropero = app.switches["Ropero"]
        if ropero.waitForExistence(timeout: 3) { ropero.tap(); pause(0.2) }

        let postres = app.switches["Postres"]
        if postres.waitForExistence(timeout: 3) { postres.tap(); pause(0.2) }

        snap("06-form-tags-on")

        // Scroll back up so time + type are visible in the same frame
        app.swipeDown(); pause(0.3)
        snap("07-form-basketball-complete")

        // ── 6. Add the event ─────────────────────────────────────────────

        // The "Add" button sits in the navigation bar toolbar
        let addBtn = app.navigationBars.buttons["Add"]
        if addBtn.waitForExistence(timeout: 3) { addBtn.tap() }
        sleep(1)
        snap("08-calendar-with-event")

        // ── 7. Income — shows the basketball entry (40 €) ────────────────

        app.tabBars.buttons["Income"].tap(); sleep(1)
        snap("09-income-with-entry")

        // ── 8. Chat — type and send a message ────────────────────────────

        app.tabBars.buttons["Chat"].tap(); sleep(1)

        // SwiftUI TextField(axis:.vertical) can surface as textField or textView
        var input = app.textFields["messageInput"]
        if !input.waitForExistence(timeout: 2) {
            input = app.textViews["messageInput"]
        }
        if !input.exists { input = app.textViews.firstMatch }

        input.tap(); pause(0.5)
        input.typeText("What events do I have this week?")
        pause(0.3)
        snap("10-chat-typing")

        tap("Send")
        sleep(4)   // stub delay 0.6 s + UI render
        snap("11-chat-response")

        // Dismiss keyboard before switching tabs (otherwise tab bar tap fails)
        if app.keyboards.count > 0 {
            app.coordinate(withNormalizedOffset: CGVector(dx: 0.5, dy: 0.3)).tap()
            pause(0.5)
        }

        // ── 9. Calendar — final view ─────────────────────────────────────

        app.tabBars.buttons["Calendar"].tap(); pause(0.5)
        snap("12-calendar-final")
    }
}
