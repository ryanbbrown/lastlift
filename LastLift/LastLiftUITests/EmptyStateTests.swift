import XCTest

final class EmptyStateTests: XCTestCase {
    let app = XCUIApplication()

    override func setUp() {
        continueAfterFailure = false
        app.launchArguments = ["--reset-data"]
        app.launch()
    }

    func testDashboard_showsEmptyState() {
        XCTAssertTrue(app.staticTexts["No Exercise Groups"].waitForExistence(timeout: 3))
    }

    func testWorkoutsTab_showsEmptyState() {
        app.tabBars.buttons["Workouts"].tap()
        XCTAssertTrue(app.staticTexts["No Workouts"].waitForExistence(timeout: 3))
    }

    func testExercisesTab_showsEmptyState() {
        app.tabBars.buttons["Exercises"].tap()
        XCTAssertTrue(app.staticTexts["No Exercise Groups"].waitForExistence(timeout: 3))
    }
}
