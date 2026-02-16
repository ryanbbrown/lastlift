import XCTest

final class RecordWorkoutTests: XCTestCase {
    let app = XCUIApplication()

    override func setUp() {
        continueAfterFailure = false
        app.launchArguments = ["--reset-data"]
        app.launch()
    }

    func testRecordWorkout_showsOnDashboard() {
        createGroupWithExercise(groupName: "Push", exerciseName: "Push-ups")

        // Go to Home tab
        app.tabBars.buttons["Home"].tap()

        // Tap "+" to record workout
        app.buttons["recordWorkoutButton"].tap()
        XCTAssertTrue(app.navigationBars["Record Workout"].waitForExistence(timeout: 3))

        // Select the exercise
        app.buttons["exercisePicker_Push-ups"].tap()

        // Save
        app.buttons["saveWorkoutButton"].tap()

        // Verify dashboard shows the exercise group card with the exercise
        let exerciseRow = app.descendants(matching: .any)["exerciseRow_Push-ups"]
        XCTAssertTrue(exerciseRow.waitForExistence(timeout: 5))
    }

    func testRecordWorkout_appearsInHistory() {
        createGroupWithExercise(groupName: "Pull", exerciseName: "Pull-ups")

        // Record a workout
        app.tabBars.buttons["Home"].tap()
        app.buttons["recordWorkoutButton"].tap()
        app.buttons["exercisePicker_Pull-ups"].tap()
        app.buttons["saveWorkoutButton"].tap()

        // Check Workouts tab
        app.tabBars.buttons["Workouts"].tap()

        // Verify a workout cell exists
        XCTAssertTrue(app.cells.firstMatch.waitForExistence(timeout: 5))
    }

    // MARK: - Helpers

    private func createGroupWithExercise(groupName: String, exerciseName: String) {
        app.tabBars.buttons["Exercises"].tap()

        app.buttons["add-group-button"].tap()
        let nameField = app.textFields["group-name-field"]
        XCTAssertTrue(nameField.waitForExistence(timeout: 3))
        nameField.tap()
        nameField.typeText(groupName)
        app.buttons["save-group-button"].tap()

        XCTAssertTrue(app.buttons["group-row-\(groupName)"].waitForExistence(timeout: 3))
        app.buttons["group-row-\(groupName)"].tap()

        app.buttons["add-exercise-button"].tap()
        let exerciseField = app.textFields["exercise-name-field"]
        XCTAssertTrue(exerciseField.waitForExistence(timeout: 3))
        exerciseField.tap()
        exerciseField.typeText(exerciseName)
        app.buttons["save-exercise-button"].tap()

        // Wait for exercise to appear in the group detail
        XCTAssertTrue(app.descendants(matching: .any)["exercise-row-\(exerciseName)"].waitForExistence(timeout: 5))
    }
}
