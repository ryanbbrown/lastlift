import Foundation
import SwiftData

@Model
final class WorkoutExercise {
    var sets: Int
    var createdAt: Date
    var updatedAt: Date

    var workout: Workout?
    var exercise: Exercise?

    init(sets: Int, workout: Workout? = nil, exercise: Exercise? = nil) {
        self.sets = sets
        self.workout = workout
        self.exercise = exercise
        self.createdAt = Date()
        self.updatedAt = Date()
    }
}
