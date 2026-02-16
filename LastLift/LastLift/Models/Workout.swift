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
}
