import SwiftUI
import SwiftData

/// Detail view for viewing and editing a single workout
struct WorkoutDetailView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    @Bindable var workout: Workout
    @State private var isEditing = false
    @State private var showDeleteConfirmation = false

    var body: some View {
        List {
            dateSection
            notesSection
            exercisesSection
            if isEditing {
                deleteSection
            }
        }
        .navigationTitle("Workout Details")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .primaryAction) {
                Button(isEditing ? "Done" : "Edit") {
                    isEditing.toggle()
                }
                .accessibilityIdentifier("editWorkoutButton")
            }
        }
        .confirmationDialog("Delete Workout", isPresented: $showDeleteConfirmation, titleVisibility: .visible) {
            Button("Delete", role: .destructive) { deleteWorkout() }
        } message: {
            Text("This action cannot be undone.")
        }
        .accessibilityIdentifier("workoutDetailView")
    }

    // MARK: - Sections

    private var dateSection: some View {
        Section("Date") {
            if isEditing {
                DatePicker("Date", selection: $workout.workoutDate, displayedComponents: .date)
                    .accessibilityIdentifier("editWorkoutDatePicker")
            } else {
                Text(workout.workoutDate, format: .dateTime.weekday(.wide).month(.wide).day().year())
            }
        }
    }

    private var notesSection: some View {
        Section("Notes") {
            if isEditing {
                TextField("Notes", text: $workout.notes, axis: .vertical)
                    .lineLimit(3)
                    .accessibilityIdentifier("editWorkoutNotesField")
            } else if workout.notes.isEmpty {
                Text("No notes")
                    .foregroundStyle(.secondary)
            } else {
                Text(workout.notes)
            }
        }
    }

    private var sortedWorkoutExercises: [WorkoutExercise] {
        workout.workoutExercises.sorted { ($0.exercise?.name ?? "") < ($1.exercise?.name ?? "") }
    }

    private var exercisesSection: some View {
        Section("Exercises") {
            ForEach(sortedWorkoutExercises) { workoutExercise in
                WorkoutExerciseRow(workoutExercise: workoutExercise, isEditing: isEditing)
            }
            .onDelete(perform: removeExercises)
            .deleteDisabled(!isEditing)
        }
    }

    private var deleteSection: some View {
        Section {
            Button("Delete Workout", role: .destructive) {
                showDeleteConfirmation = true
            }
            .accessibilityIdentifier("deleteWorkoutButton")
        }
    }

    // MARK: - Actions

    /// Removes exercises from the workout and recalculates their lastPerformed dates
    private func removeExercises(at offsets: IndexSet) {
        for index in offsets {
            let workoutExercise = sortedWorkoutExercises[index]
            let exercise = workoutExercise.exercise
            modelContext.delete(workoutExercise)
            exercise?.recalculateLastPerformed()
        }
    }

    /// Deletes the entire workout and recalculates lastPerformed on all affected exercises
    private func deleteWorkout() {
        workout.deleteAndRecalculate(from: modelContext)
        UIImpactFeedbackGenerator(style: .medium).impactOccurred()
        dismiss()
    }
}

// MARK: - Workout Exercise Row

private struct WorkoutExerciseRow: View {
    @Bindable var workoutExercise: WorkoutExercise
    let isEditing: Bool

    var body: some View {
        if let exercise = workoutExercise.exercise {
            HStack {
                Text(exercise.name)
                Spacer()
                if isEditing {
                    Stepper("\(workoutExercise.sets) sets", value: $workoutExercise.sets, in: 1...20)
                        .accessibilityIdentifier("editSetStepper_\(exercise.name)")
                } else {
                    Text("\(workoutExercise.sets) sets")
                        .foregroundStyle(.secondary)
                }
            }
            .accessibilityIdentifier("workoutExercise_\(exercise.name)")
        }
    }
}
