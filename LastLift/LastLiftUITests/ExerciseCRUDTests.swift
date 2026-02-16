import XCTest

final class ExerciseCRUDTests: XCTestCase {
    let app = XCUIApplication()

    override func setUp() {
        continueAfterFailure = false
        app.launchArguments = ["--reset-data"]
        app.launch()
    }

    func testCreateGroupAndExercise() {
        // Navigate to Exercises tab
        app.tabBars.buttons["Exercises"].tap()

        // Create a group
        app.buttons["add-group-button"].tap()
        let nameField = app.textFields["group-name-field"]
        XCTAssertTrue(nameField.waitForExistence(timeout: 3))
        nameField.tap()
        nameField.typeText("Upper Body")
        app.buttons["save-group-button"].tap()

        // Verify group appears and navigate into it
        let groupRow = app.buttons["group-row-Upper Body"]
        XCTAssertTrue(groupRow.waitForExistence(timeout: 3))
        groupRow.tap()

        // Add an exercise
        app.buttons["add-exercise-button"].tap()
        let exerciseNameField = app.textFields["exercise-name-field"]
        XCTAssertTrue(exerciseNameField.waitForExistence(timeout: 3))
        exerciseNameField.tap()
        exerciseNameField.typeText("Bench Press")
        app.buttons["save-exercise-button"].tap()

        // Verify exercise appears — search all element types
        let exerciseElement = app.descendants(matching: .any)["exercise-row-Bench Press"]
        XCTAssertTrue(exerciseElement.waitForExistence(timeout: 5))
    }

    func testDeleteGroup() {
        app.tabBars.buttons["Exercises"].tap()

        // Create a group
        app.buttons["add-group-button"].tap()
        let nameField = app.textFields["group-name-field"]
        XCTAssertTrue(nameField.waitForExistence(timeout: 3))
        nameField.tap()
        nameField.typeText("Temp Group")
        app.buttons["save-group-button"].tap()
        XCTAssertTrue(app.buttons["group-row-Temp Group"].waitForExistence(timeout: 3))

        // Swipe to delete
        app.buttons["group-row-Temp Group"].swipeLeft()
        app.buttons["Delete"].tap()

        // Confirm deletion in the confirmation dialog
        let confirmDelete = app.buttons["Delete"]
        if confirmDelete.waitForExistence(timeout: 2) {
            confirmDelete.tap()
        }

        // Verify empty state
        XCTAssertTrue(app.staticTexts["No Exercise Groups"].waitForExistence(timeout: 3))
    }
}
