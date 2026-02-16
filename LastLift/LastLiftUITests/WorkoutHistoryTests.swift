import XCTest

final class WorkoutHistoryTests: XCTestCase {
    let app = XCUIApplication()

    override func setUp() {
        continueAfterFailure = false
        app.launchArguments = ["--reset-data"]
        app.launch()
    }

    func testViewWorkoutDetail() {
        createGroupExerciseAndWorkout(groupName: "Core", exerciseName: "Plank")

        // Navigate to Workouts tab
        app.tabBars.buttons["Workouts"].tap()

        // Tap on the workout
        let workoutCell = app.cells.firstMatch
        XCTAssertTrue(workoutCell.waitForExistence(timeout: 5))
        workoutCell.tap()

        // Verify detail view shows
        XCTAssertTrue(app.navigationBars["Workout Details"].waitForExistence(timeout: 3))
    }

    func testDeleteWorkout_recalculatesLastPerformed() {
        createGroupExerciseAndWorkout(groupName: "Arms", exerciseName: "Curls")

        // Navigate to Workouts tab
        app.tabBars.buttons["Workouts"].tap()

        // Tap into the workout detail
        let workoutCell = app.cells.firstMatch
        XCTAssertTrue(workoutCell.waitForExistence(timeout: 5))
        workoutCell.tap()
        XCTAssertTrue(app.navigationBars["Workout Details"].waitForExistence(timeout: 3))

        // Tap Edit, then Delete Workout
        let editButton = app.buttons["editWorkoutButton"]
        XCTAssertTrue(editButton.waitForExistence(timeout: 3))
        editButton.tap()

        let deleteWorkoutButton = app.buttons["deleteWorkoutButton"]
        XCTAssertTrue(deleteWorkoutButton.waitForExistence(timeout: 3))
        deleteWorkoutButton.tap()

        // Confirm delete in the confirmation dialog
        let confirmDelete = app.buttons["Delete"]
        XCTAssertTrue(confirmDelete.waitForExistence(timeout: 3))
        confirmDelete.tap()

        // Verify workouts list is empty (we're popped back)
        XCTAssertTrue(app.staticTexts["No Workouts"].waitForExistence(timeout: 5))

        // Go to dashboard and verify exercise shows "Never"
        app.tabBars.buttons["Home"].tap()
        XCTAssertTrue(app.staticTexts["Never"].waitForExistence(timeout: 5))
    }

    // MARK: - Helpers

    private func createGroupExerciseAndWorkout(groupName: String, exerciseName: String) {
        // Create group + exercise
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
        XCTAssertTrue(app.descendants(matching: .any)["exercise-row-\(exerciseName)"].waitForExistence(timeout: 5))

        // Record a workout
        app.tabBars.buttons["Home"].tap()
        app.buttons["recordWorkoutButton"].tap()
        XCTAssertTrue(app.navigationBars["Record Workout"].waitForExistence(timeout: 3))
        app.buttons["exercisePicker_\(exerciseName)"].tap()
        app.buttons["saveWorkoutButton"].tap()
    }
}
