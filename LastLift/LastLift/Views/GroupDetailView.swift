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
    @State private var showingEditGroup = false

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
                .buttonStyle(.plain)
                .listRowBackground(Color.clear)
                .accessibilityIdentifier("exercise-row-\(exercise.name)")
            }
            .onDelete(perform: confirmDeleteExercise)
        }
        .scrollContentBackground(.hidden)
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
            ToolbarItem(placement: .principal) {
                HStack(spacing: 8) {
                    RoundedRectangle(cornerRadius: 2)
                        .fill(Color(hex: group.color))
                        .frame(width: 4, height: 20)
                    Text(group.name)
                        .font(.headline)
                }
            }
            ToolbarItem(placement: .primaryAction) {
                HStack(spacing: 12) {
                    Button {
                        showingEditGroup = true
                    } label: {
                        Image(systemName: "pencil")
                    }
                    .accessibilityLabel("Edit Group")

                    Button {
                        showingAddExercise = true
                    } label: {
                        Image(systemName: "plus")
                    }
                    .accessibilityIdentifier("add-exercise-button")
                }
            }
        }
        .sheet(item: $exerciseToEdit) { exercise in
            EditExerciseSheet(group: group, exercise: exercise)
        }
        .sheet(isPresented: $showingAddExercise) {
            EditExerciseSheet(group: group, exercise: nil)
        }
        .sheet(isPresented: $showingEditGroup) {
            EditGroupSheet(group: group)
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

/// Row displaying an exercise's name and description with card styling
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
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(10)
        .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 10))
    }
}
