import SwiftUI
import SwiftData

struct DashboardView: View {
    @Query(sort: \ExerciseGroup.createdAt) private var groups: [ExerciseGroup]
    @State private var showRecordWorkout = false

    var body: some View {
        NavigationStack {
            ScrollView {
                if groups.isEmpty {
                    ContentUnavailableView(
                        "No Exercise Groups",
                        systemImage: "dumbbell",
                        description: Text("Add some exercises to get started.")
                    )
                } else {
                    LazyVStack(spacing: 12) {
                        ForEach(groups) { group in
                            ExerciseGroupCard(
                                group: group,
                                exercises: group.prioritizedExercises
                            )
                        }
                    }
                    .padding()
                }
            }
            .navigationTitle("LastLift")
            .toolbar {
                ToolbarItem(placement: .primaryAction) {
                    Button {
                        showRecordWorkout = true
                    } label: {
                        Image(systemName: "plus")
                    }
                    .accessibilityLabel("Record Workout")
                    .accessibilityIdentifier("recordWorkoutButton")
                }
            }
            .sheet(isPresented: $showRecordWorkout) {
                RecordWorkoutView()
            }
        }
        .accessibilityIdentifier("dashboardView")
    }
}
