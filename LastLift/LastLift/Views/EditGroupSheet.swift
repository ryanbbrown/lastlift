import SwiftUI
import SwiftData

/// Sheet for creating or editing an exercise group
struct EditGroupSheet: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss

    let group: ExerciseGroup?

    @State private var name: String = ""
    @State private var color: String = "#9333ea"
    @State private var numExercisesToShow: Int = 2

    private var isEditing: Bool { group != nil }

    var body: some View {
        NavigationStack {
            Form {
                Section {
                    TextField("Group Name", text: $name)
                        .accessibilityIdentifier("group-name-field")
                }

                Section("Color") {
                    ColorPickerField(selectedColor: $color)
                }

                Section {
                    Stepper("Exercises to show: \(numExercisesToShow)", value: $numExercisesToShow, in: 1...10)
                        .accessibilityIdentifier("exercises-to-show-stepper")
                }
            }
            .navigationTitle(isEditing ? "Edit Group" : "New Group")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") { save() }
                        .disabled(name.trimmingCharacters(in: .whitespaces).isEmpty)
                        .accessibilityIdentifier("save-group-button")
                }
            }
            .onAppear {
                if let group {
                    name = group.name
                    color = group.color
                    numExercisesToShow = group.numExercisesToShow
                }
            }
        }
    }

    private func save() {
        let trimmedName = name.trimmingCharacters(in: .whitespaces)
        if let group {
            group.name = trimmedName
            group.color = color
            group.numExercisesToShow = numExercisesToShow
            group.updatedAt = Date()
        } else {
            let newGroup = ExerciseGroup(name: trimmedName, color: color, numExercisesToShow: numExercisesToShow)
            modelContext.insert(newGroup)
        }
        UINotificationFeedbackGenerator().notificationOccurred(.success)
        dismiss()
    }
}
