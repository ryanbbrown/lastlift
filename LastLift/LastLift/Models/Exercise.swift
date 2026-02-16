import Foundation
import SwiftData

@Model
final class Exercise {
    var name: String
    var exerciseDescription: String
    var lastPerformed: Date?
    var createdAt: Date
    var updatedAt: Date

    var group: ExerciseGroup?

    @Relationship(inverse: \WorkoutExercise.exercise)
    var workoutExercises: [WorkoutExercise] = []

    init(name: String, exerciseDescription: String = "", group: ExerciseGroup? = nil) {
        self.name = name
        self.exerciseDescription = exerciseDescription
        self.group = group
        self.createdAt = Date()
        self.updatedAt = Date()
    }

    /// Recalculates lastPerformed by finding the max workout date from remaining WorkoutExercises
    func recalculateLastPerformed() {
        lastPerformed = workoutExercises
            .compactMap { $0.workout?.workoutDate }
            .max()
        updatedAt = Date()
    }
}
