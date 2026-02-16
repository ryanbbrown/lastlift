import SwiftUI

/// Expandable card displaying a group's prioritized exercises on the dashboard
struct ExerciseGroupCard: View {
    let group: ExerciseGroup
    let exercises: [Exercise]

    @State private var isExpanded = true
    @State private var exerciseToSkip: Exercise?

    var body: some View {
        DisclosureGroup(isExpanded: $isExpanded) {
            LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 8) {
                ForEach(exercises) { exercise in
                    ExerciseCardRow(exercise: exercise) {
                        exerciseToSkip = exercise
                    }
                }
            }
            .padding(.top, 4)
        } label: {
            Text(group.name)
                .font(.headline)
                .foregroundStyle(Color(hex: group.color))
        }
        .tint(Color(hex: group.color))
        .padding()
        .background(.black, in: RoundedRectangle(cornerRadius: 12))
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(Color(hex: group.color).opacity(0.5), lineWidth: 1)
        )
        .accessibilityIdentifier("exerciseGroupCard_\(group.name)")
        .confirmationDialog(
            "Skip \(exerciseToSkip?.name ?? "Exercise")?",
            isPresented: $exerciseToSkip.isPresent(),
            titleVisibility: .visible
        ) {
            Button("Skip") {
                if let exercise = exerciseToSkip {
                    exercise.lastSkippedAt = Date()
                    UIImpactFeedbackGenerator(style: .medium).impactOccurred()
                }
                exerciseToSkip = nil
            }
        } message: {
            Text("This exercise will move to the back of the queue.")
        }
    }
}

private struct ExerciseCardRow: View {
    let exercise: Exercise
    let onSkip: () -> Void
    @AppStorage("dateFormat") private var dateFormat: DateFormatSetting = .relative

    var body: some View {
        Button(action: onSkip) {
            VStack(alignment: .leading, spacing: 2) {
                Text(exercise.name)
                    .font(.subheadline)
                    .fontWeight(.medium)
                Text(dateLabel)
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(8)
            .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 8))
        }
        .buttonStyle(.plain)
        .accessibilityIdentifier("exerciseRow_\(exercise.name)")
    }

    private var dateLabel: String {
        let wasSkipped = exercise.lastSkippedAt.map { skipDate in
            exercise.lastPerformed.map { skipDate > $0 } ?? true
        } ?? false

        if wasSkipped {
            if let date = exercise.lastSkippedAt {
                return dateFormat.format(date) + " (skipped)"
            }
            return "Never"
        }

        guard let date = exercise.lastPerformed else { return "Never" }
        return dateFormat.format(date)
    }
}
