import SwiftUI
import SwiftData

/// Sheet for creating or editing an exercise within a group
struct EditExerciseSheet: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss

    let group: ExerciseGroup
    let exercise: Exercise?

    @State private var name: String = ""
    @State private var exerciseDescription: String = ""

    private var isEditing: Bool { exercise != nil }

    var body: some View {
        NavigationStack {
            Form {
                Section {
                    TextField("Exercise Name", text: $name)
                        .accessibilityIdentifier("exercise-name-field")
                }

                Section {
                    TextField("Description (sets, reps, etc.)", text: $exerciseDescription)
                        .accessibilityIdentifier("exercise-description-field")
                }
            }
            .navigationTitle(isEditing ? "Edit Exercise" : "New Exercise")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") { save() }
                        .disabled(name.trimmingCharacters(in: .whitespaces).isEmpty)
                        .accessibilityIdentifier("save-exercise-button")
                }
            }
            .onAppear {
                if let exercise {
                    name = exercise.name
                    exerciseDescription = exercise.exerciseDescription
                }
            }
        }
    }

    private func save() {
        let trimmedName = name.trimmingCharacters(in: .whitespaces)
        if let exercise {
            exercise.name = trimmedName
            exercise.exerciseDescription = exerciseDescription
            exercise.updatedAt = Date()
        } else {
            let newExercise = Exercise(name: trimmedName, exerciseDescription: exerciseDescription, group: group)
            modelContext.insert(newExercise)
        }
        UINotificationFeedbackGenerator().notificationOccurred(.success)
        dismiss()
    }
}
