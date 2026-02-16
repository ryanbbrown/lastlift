import SwiftUI
import SwiftData

struct WorkoutHistoryView: View {
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \Workout.workoutDate, order: .reverse) private var workouts: [Workout]

    @State private var workoutToDelete: Workout?

    var body: some View {
        NavigationStack {
            List {
                ForEach(workouts) { workout in
                    NavigationLink(value: workout) {
                        WorkoutRow(workout: workout)
                    }
                    .accessibilityIdentifier("workoutRow_\(workout.workoutDate.formatted(date: .numeric, time: .omitted))")
                }
                .onDelete(perform: confirmDeleteWorkout)
            }
            .overlay {
                if workouts.isEmpty {
                    ContentUnavailableView(
                        "No Workouts",
                        systemImage: "clock",
                        description: Text("Record a workout from the Home tab.")
                    )
                }
            }
            .navigationTitle("Workouts")
            .navigationDestination(for: Workout.self) { workout in
                WorkoutDetailView(workout: workout)
            }
            .confirmationDialog(
                "Delete Workout?",
                isPresented: Binding(get: { workoutToDelete != nil }, set: { if !$0 { workoutToDelete = nil } }),
                titleVisibility: .visible
            ) {
                Button("Delete", role: .destructive) {
                    if let workout = workoutToDelete {
                        let affectedExercises = workout.workoutExercises.compactMap(\.exercise)
                        modelContext.delete(workout)
                        try? modelContext.save()
                        for exercise in affectedExercises {
                            exercise.recalculateLastPerformed()
                        }
                        UIImpactFeedbackGenerator(style: .medium).impactOccurred()
                    }
                    workoutToDelete = nil
                }
            } message: {
                Text("This action cannot be undone.")
            }
        }
        .accessibilityIdentifier("workoutHistoryView")
    }

    private func confirmDeleteWorkout(at offsets: IndexSet) {
        if let index = offsets.first {
            workoutToDelete = workouts[index]
        }
    }
}

// MARK: - Workout Row

private struct WorkoutRow: View {
    let workout: Workout

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(workout.workoutDate, format: .dateTime.weekday(.wide).month(.wide).day().year())
                .font(.headline)
            HStack(spacing: 12) {
                Label("\(workout.workoutExercises.count) exercises", systemImage: "dumbbell")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                if !workout.notes.isEmpty {
                    Text(workout.notes)
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                        .lineLimit(1)
                }
            }
        }
        .padding(.vertical, 2)
    }
}
