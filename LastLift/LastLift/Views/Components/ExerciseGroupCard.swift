import SwiftUI

/// Expandable card displaying a group's prioritized exercises on the dashboard
struct ExerciseGroupCard: View {
    let group: ExerciseGroup
    let exercises: [Exercise]

    @State private var isExpanded = true

    var body: some View {
        DisclosureGroup(isExpanded: $isExpanded) {
            LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 8) {
                ForEach(exercises) { exercise in
                    ExerciseRow(exercise: exercise)
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
    }
}

private struct ExerciseRow: View {
    let exercise: Exercise

    var body: some View {
        VStack(alignment: .leading, spacing: 2) {
            Text(exercise.name)
                .font(.subheadline)
                .fontWeight(.medium)
            Text(relativeDate)
                .font(.caption)
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(8)
        .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 8))
        .accessibilityIdentifier("exerciseRow_\(exercise.name)")
    }

    private var relativeDate: String {
        guard let date = exercise.lastPerformed else { return "Never" }
        let formatter = RelativeDateTimeFormatter()
        formatter.unitsStyle = .full
        return formatter.localizedString(for: date, relativeTo: .now)
    }
}
