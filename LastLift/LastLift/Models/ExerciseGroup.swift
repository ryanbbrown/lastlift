import Foundation
import SwiftData

@Model
final class ExerciseGroup {
    var name: String
    var color: String
    var numExercisesToShow: Int
    var createdAt: Date
    var updatedAt: Date

    @Relationship(deleteRule: .cascade, inverse: \Exercise.group)
    var exercises: [Exercise] = []

    init(name: String, color: String, numExercisesToShow: Int = 2) {
        self.name = name
        self.color = color
        self.numExercisesToShow = numExercisesToShow
        self.createdAt = Date()
        self.updatedAt = Date()
    }

    /// Returns exercises sorted by longest gap since last activity (performed or skipped), limited to numExercisesToShow
    var prioritizedExercises: [Exercise] {
        let sorted = exercises.sorted { a, b in
            let dateA = [a.lastPerformed, a.lastSkippedAt].compactMap { $0 }.max()
            let dateB = [b.lastPerformed, b.lastSkippedAt].compactMap { $0 }.max()
            switch (dateA, dateB) {
            case (nil, nil):
                return a.name < b.name
            case (nil, _):
                return true
            case (_, nil):
                return false
            case let (dA?, dB?):
                return dA < dB
            }
        }
        return Array(sorted.prefix(numExercisesToShow))
    }
}
