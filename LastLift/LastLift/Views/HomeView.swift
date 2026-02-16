import SwiftUI

/// Root tab view containing Dashboard, Workouts, and Exercises tabs
struct HomeView: View {
    var body: some View {
        TabView {
            Tab("Home", systemImage: "house.fill") {
                DashboardView()
            }

            Tab("Workouts", systemImage: "clock.fill") {
                WorkoutHistoryView()
            }

            Tab("Exercises", systemImage: "dumbbell.fill") {
                EditExercisesView()
            }
        }
    }
}
