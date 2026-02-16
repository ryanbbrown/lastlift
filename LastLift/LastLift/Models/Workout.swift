import Foundation
import SwiftData

@Model
final class Workout {
    var workoutDate: Date
    var notes: String
    var createdAt: Date
    var updatedAt: Date

    @Relationship(deleteRule: .cascade, inverse: \WorkoutExercise.workout)
    var workoutExercises: [WorkoutExercise] = []

    init(workoutDate: Date = Date(), notes: String = "") {
        self.workoutDate = workoutDate
        self.notes = notes
        self.createdAt = Date()
        self.updatedAt = Date()
    }

    /// Deletes this workout and recalculates lastPerformed on all affected exercises
    func deleteAndRecalculate(from context: ModelContext) {
        let affectedExercises = workoutExercises.compactMap(\.exercise)
        context.delete(self)
        try? context.save()
        for exercise in affectedExercises {
            exercise.recalculateLastPerformed()
        }
    }
}
