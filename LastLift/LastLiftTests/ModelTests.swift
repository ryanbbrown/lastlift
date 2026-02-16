import XCTest
import SwiftData
@testable import LastLift

final class ModelTests: XCTestCase {
    var container: ModelContainer!
    var context: ModelContext!

    override func setUp() {
        let schema = Schema([ExerciseGroup.self, Exercise.self, Workout.self, WorkoutExercise.self])
        let config = ModelConfiguration(isStoredInMemoryOnly: true)
        container = try! ModelContainer(for: schema, configurations: [config])
        context = ModelContext(container)
    }

    override func tearDown() {
        container = nil
        context = nil
    }

    // MARK: - prioritizedExercises

    func testPrioritizedExercises_nullsFirst() throws {
        let group = ExerciseGroup(name: "Upper", color: "#ff0000", numExercisesToShow: 3)
        context.insert(group)

        let e1 = Exercise(name: "Bench", group: group)
        e1.lastPerformed = Date().addingTimeInterval(-86400) // 1 day ago
        let e2 = Exercise(name: "Curl", group: group) // nil lastPerformed
        let e3 = Exercise(name: "Press", group: group)
        e3.lastPerformed = Date().addingTimeInterval(-172800) // 2 days ago
        context.insert(e1)
        context.insert(e2)
        context.insert(e3)
        try context.save()

        let prioritized = group.prioritizedExercises
        XCTAssertEqual(prioritized[0].name, "Curl", "Nil lastPerformed should come first")
        XCTAssertEqual(prioritized[1].name, "Press", "Oldest lastPerformed should come second")
        XCTAssertEqual(prioritized[2].name, "Bench", "Most recent should come last")
    }

    func testPrioritizedExercises_limitsToNumExercisesToShow() throws {
        let group = ExerciseGroup(name: "Legs", color: "#00ff00", numExercisesToShow: 2)
        context.insert(group)

        let e1 = Exercise(name: "Squat", group: group)
        let e2 = Exercise(name: "Lunge", group: group)
        let e3 = Exercise(name: "Deadlift", group: group)
        context.insert(e1)
        context.insert(e2)
        context.insert(e3)
        try context.save()

        let prioritized = group.prioritizedExercises
        XCTAssertEqual(prioritized.count, 2, "Should limit to numExercisesToShow")
    }

    func testPrioritizedExercises_nullsSortAlphabetically() throws {
        let group = ExerciseGroup(name: "Core", color: "#0000ff", numExercisesToShow: 3)
        context.insert(group)

        let e1 = Exercise(name: "Plank", group: group)
        let e2 = Exercise(name: "Crunch", group: group)
        let e3 = Exercise(name: "Ab Wheel", group: group)
        context.insert(e1)
        context.insert(e2)
        context.insert(e3)
        try context.save()

        let prioritized = group.prioritizedExercises
        XCTAssertEqual(prioritized[0].name, "Ab Wheel")
        XCTAssertEqual(prioritized[1].name, "Crunch")
        XCTAssertEqual(prioritized[2].name, "Plank")
    }

    // MARK: - recalculateLastPerformed

    func testRecalculateLastPerformed_findsMaxDate() throws {
        let exercise = Exercise(name: "Bench")
        context.insert(exercise)

        let oldDate = Date().addingTimeInterval(-172800) // 2 days ago
        let recentDate = Date().addingTimeInterval(-86400) // 1 day ago

        let workout1 = Workout(workoutDate: oldDate)
        let workout2 = Workout(workoutDate: recentDate)
        context.insert(workout1)
        context.insert(workout2)

        let we1 = WorkoutExercise(sets: 3, workout: workout1, exercise: exercise)
        let we2 = WorkoutExercise(sets: 3, workout: workout2, exercise: exercise)
        context.insert(we1)
        context.insert(we2)
        try context.save()

        exercise.recalculateLastPerformed()

        XCTAssertEqual(
            exercise.lastPerformed!.timeIntervalSinceReferenceDate,
            recentDate.timeIntervalSinceReferenceDate,
            accuracy: 1.0,
            "Should find the most recent workout date"
        )
    }

    func testRecalculateLastPerformed_nilWhenNoWorkoutExercises() throws {
        let exercise = Exercise(name: "Bench")
        exercise.lastPerformed = Date()
        context.insert(exercise)
        try context.save()

        exercise.recalculateLastPerformed()

        XCTAssertNil(exercise.lastPerformed, "Should be nil when no workout exercises remain")
    }

    // MARK: - Workout updates lastPerformed

    func testWorkoutCreation_updatesLastPerformed() throws {
        let exercise = Exercise(name: "Squat")
        context.insert(exercise)

        let workoutDate = Date()
        let workout = Workout(workoutDate: workoutDate)
        context.insert(workout)

        let we = WorkoutExercise(sets: 4, workout: workout, exercise: exercise)
        context.insert(we)
        try context.save()

        exercise.recalculateLastPerformed()

        XCTAssertNotNil(exercise.lastPerformed)
        XCTAssertEqual(
            exercise.lastPerformed!.timeIntervalSinceReferenceDate,
            workoutDate.timeIntervalSinceReferenceDate,
            accuracy: 1.0
        )
    }

    // MARK: - Cascade deletes

    func testDeleteGroup_cascadesToExercises() throws {
        let group = ExerciseGroup(name: "Upper", color: "#ff0000")
        context.insert(group)

        let e1 = Exercise(name: "Bench", group: group)
        let e2 = Exercise(name: "Curl", group: group)
        context.insert(e1)
        context.insert(e2)
        try context.save()

        let exercisesBefore = try context.fetch(FetchDescriptor<Exercise>())
        XCTAssertEqual(exercisesBefore.count, 2)

        context.delete(group)
        try context.save()

        let exercisesAfter = try context.fetch(FetchDescriptor<Exercise>())
        XCTAssertEqual(exercisesAfter.count, 0, "Deleting group should cascade delete exercises")
    }

    func testDeleteWorkout_cascadesToWorkoutExercises() throws {
        let workout = Workout(workoutDate: Date())
        context.insert(workout)

        let exercise = Exercise(name: "Bench")
        context.insert(exercise)

        let we = WorkoutExercise(sets: 3, workout: workout, exercise: exercise)
        context.insert(we)
        try context.save()

        let weBefore = try context.fetch(FetchDescriptor<WorkoutExercise>())
        XCTAssertEqual(weBefore.count, 1)

        context.delete(workout)
        try context.save()

        let weAfter = try context.fetch(FetchDescriptor<WorkoutExercise>())
        XCTAssertEqual(weAfter.count, 0, "Deleting workout should cascade delete workout exercises")
    }
}
