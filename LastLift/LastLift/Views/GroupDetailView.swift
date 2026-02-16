import SwiftUI
import SwiftData

/// Shows exercises within a group with add/edit/delete capabilities
struct GroupDetailView: View {
    @Environment(\.modelContext) private var modelContext
    @Query private var exercises: [Exercise]

    let group: ExerciseGroup

    @State private var exerciseToEdit: Exercise?
    @State private var showingAddExercise = false
    @State private var exerciseToDelete: Exercise?

    init(group: ExerciseGroup) {
        self.group = group
        let groupID = group.persistentModelID
        _exercises = Query(
            filter: #Predicate<Exercise> { exercise in
                exercise.group?.persistentModelID == groupID
            },
            sort: \Exercise.name
        )
    }

    var body: some View {
        List {
            ForEach(exercises) { exercise in
                Button {
                    exerciseToEdit = exercise
                } label: {
                    ExerciseRow(exercise: exercise)
                }
                .accessibilityIdentifier("exercise-row-\(exercise.name)")
            }
            .onDelete(perform: confirmDeleteExercise)
        }
        .overlay {
            if exercises.isEmpty {
                ContentUnavailableView {
                    Label("No Exercises", systemImage: "figure.strengthtraining.traditional")
                } description: {
                    Text("Tap + to add an exercise to this group.")
                }
            }
        }
        .navigationTitle(group.name)
        .toolbar {
            ToolbarItem(placement: .primaryAction) {
                Button {
                    showingAddExercise = true
                } label: {
                    Image(systemName: "plus")
                }
                .accessibilityIdentifier("add-exercise-button")
            }
        }
        .sheet(item: $exerciseToEdit) { exercise in
            EditExerciseSheet(group: group, exercise: exercise)
        }
        .sheet(isPresented: $showingAddExercise) {
            EditExerciseSheet(group: group, exercise: nil)
        }
        .confirmationDialog(
            "Delete \(exerciseToDelete?.name ?? "Exercise")?",
            isPresented: $exerciseToDelete.isPresent(),
            titleVisibility: .visible
        ) {
            Button("Delete", role: .destructive) {
                if let exercise = exerciseToDelete {
                    modelContext.delete(exercise)
                    UIImpactFeedbackGenerator(style: .medium).impactOccurred()
                }
                exerciseToDelete = nil
            }
        }
    }

    private func confirmDeleteExercise(at offsets: IndexSet) {
        if let index = offsets.first {
            exerciseToDelete = exercises[index]
        }
    }
}

/// Row displaying an exercise's name and description
private struct ExerciseRow: View {
    let exercise: Exercise

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(exercise.name)
                .foregroundStyle(.primary)
            if !exercise.exerciseDescription.isEmpty {
                Text(exercise.exerciseDescription)
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
        }
    }
}
