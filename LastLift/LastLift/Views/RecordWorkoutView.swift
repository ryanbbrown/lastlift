import SwiftUI
import SwiftData

/// Sheet for recording a new workout by selecting exercises and set counts
struct RecordWorkoutView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    @Query(sort: \ExerciseGroup.createdAt) private var groups: [ExerciseGroup]

    @State private var workoutDate = Date()
    @State private var notes = ""
    @State private var selectedExercises: [SelectedExercise] = []

    var body: some View {
        NavigationStack {
            Form {
                workoutDetailsSection
                selectedExercisesSection
                exercisePickerSection
            }
            .navigationTitle("Record Workout")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                        .accessibilityIdentifier("cancelRecordWorkout")
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") { saveWorkout() }
                        .disabled(selectedExercises.isEmpty)
                        .accessibilityIdentifier("saveWorkoutButton")
                }
            }
        }
        .accessibilityIdentifier("recordWorkoutView")
    }

    // MARK: - Sections

    private var workoutDetailsSection: some View {
        Section {
            DatePicker("Date", selection: $workoutDate, displayedComponents: .date)
                .accessibilityIdentifier("workoutDatePicker")
            TextField("Notes (optional)", text: $notes, axis: .vertical)
                .lineLimit(3)
                .accessibilityIdentifier("workoutNotesField")
        }
    }

    private var selectedExercisesSection: some View {
        Section("Selected Exercises") {
            if selectedExercises.isEmpty {
                Text("Tap exercises below to add them")
                    .foregroundStyle(.secondary)
            } else {
                ForEach($selectedExercises) { $selected in
                    HStack {
                        Text(selected.exercise.name)
                        Spacer()
                        Stepper("\(selected.sets) sets", value: $selected.sets, in: 1...20)
                            .accessibilityIdentifier("setStepper_\(selected.exercise.name)")
                    }
                }
                .onDelete { offsets in
                    selectedExercises.remove(atOffsets: offsets)
                }
            }
        }
        .accessibilityIdentifier("selectedExercisesSection")
    }

    private var exercisePickerSection: some View {
        ForEach(groups) { group in
            Section(group.name) {
                let sortedExercises = group.exercises.sorted { $0.name < $1.name }
                ForEach(sortedExercises) { exercise in
                    let isSelected = selectedExercises.contains { $0.exercise.id == exercise.id }
                    Button {
                        toggleExercise(exercise)
                    } label: {
                        HStack {
                            Text(exercise.name)
                                .foregroundStyle(.primary)
                            Spacer()
                            if isSelected {
                                Image(systemName: "checkmark")
                                    .foregroundStyle(Color(hex: group.color))
                            }
                        }
                    }
                    .accessibilityIdentifier("exercisePicker_\(exercise.name)")
                }
            }
        }
    }

    // MARK: - Actions

    /// Toggles an exercise's inclusion in the workout
    private func toggleExercise(_ exercise: Exercise) {
        if let index = selectedExercises.firstIndex(where: { $0.exercise.id == exercise.id }) {
            selectedExercises.remove(at: index)
        } else {
            selectedExercises.append(SelectedExercise(exercise: exercise))
        }
    }

    /// Saves the workout with selected exercises and updates lastPerformed dates
    private func saveWorkout() {
        let workout = Workout(workoutDate: workoutDate, notes: notes.trimmingCharacters(in: .whitespacesAndNewlines))
        modelContext.insert(workout)

        for selected in selectedExercises {
            let workoutExercise = WorkoutExercise(sets: selected.sets, workout: workout, exercise: selected.exercise)
            modelContext.insert(workoutExercise)

            if selected.exercise.lastPerformed.map({ workoutDate > $0 }) ?? true {
                selected.exercise.lastPerformed = workoutDate
                selected.exercise.lastSkippedAt = nil
                selected.exercise.updatedAt = Date()
            }
        }

        UINotificationFeedbackGenerator().notificationOccurred(.success)
        dismiss()
    }
}

// MARK: - Supporting Types

private struct SelectedExercise: Identifiable {
    let id = UUID()
    let exercise: Exercise
    var sets: Int = 1
}
