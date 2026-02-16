import SwiftUI
import SwiftData

@main
struct LastLiftApp: App {
    var sharedModelContainer: ModelContainer = {
        let schema = Schema([
            ExerciseGroup.self,
            Exercise.self,
            Workout.self,
            WorkoutExercise.self,
        ])
        let inMemory = CommandLine.arguments.contains("--reset-data")
        let modelConfiguration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: inMemory)

        do {
            return try ModelContainer(for: schema, configurations: [modelConfiguration])
        } catch {
            fatalError("Could not create ModelContainer: \(error)")
        }
    }()

    var body: some Scene {
        WindowGroup {
            HomeView()
                .preferredColorScheme(.dark)
        }
        .modelContainer(sharedModelContainer)
    }
}
