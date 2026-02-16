import SwiftUI
import SwiftData

/// Home tab showing prioritized exercises from each group
struct DashboardView: View {
    @Query(sort: \ExerciseGroup.createdAt) private var groups: [ExerciseGroup]
    @State private var showRecordWorkout = false
    @State private var showSettings = false

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
                ToolbarItem(placement: .topBarLeading) {
                    Button {
                        showSettings = true
                    } label: {
                        Image(systemName: "gearshape")
                    }
                    .accessibilityLabel("Settings")
                    .accessibilityIdentifier("settingsButton")
                }
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
            .sheet(isPresented: $showSettings) {
                SettingsView()
            }
            .sheet(isPresented: $showRecordWorkout) {
                RecordWorkoutView()
            }
        }
        .accessibilityIdentifier("dashboardView")
    }
}
