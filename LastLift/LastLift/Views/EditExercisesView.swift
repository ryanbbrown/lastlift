import SwiftUI
import SwiftData

/// Main view for managing exercise groups — list, create, edit, delete
struct EditExercisesView: View {
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \ExerciseGroup.createdAt) private var groups: [ExerciseGroup]

    @State private var groupToEdit: ExerciseGroup?
    @State private var showingAddGroup = false
    @State private var groupToDelete: ExerciseGroup?

    var body: some View {
        NavigationStack {
            List {
                ForEach(groups) { group in
                    NavigationLink(value: group) {
                        GroupRow(group: group)
                    }
                    .swipeActions(edge: .leading) {
                        Button {
                            groupToEdit = group
                        } label: {
                            Label("Edit", systemImage: "pencil")
                        }
                        .tint(Color(hex: group.color))
                    }
                    .accessibilityIdentifier("group-row-\(group.name)")
                }
                .onDelete(perform: confirmDeleteGroup)
            }
            .navigationTitle("Exercises")
            .navigationDestination(for: ExerciseGroup.self) { group in
                GroupDetailView(group: group)
            }
            .toolbar {
                ToolbarItem(placement: .primaryAction) {
                    Button {
                        showingAddGroup = true
                    } label: {
                        Image(systemName: "plus")
                    }
                    .accessibilityIdentifier("add-group-button")
                }
            }
            .sheet(isPresented: $showingAddGroup) {
                EditGroupSheet(group: nil)
            }
            .sheet(item: $groupToEdit) { group in
                EditGroupSheet(group: group)
            }
            .overlay {
                if groups.isEmpty {
                    ContentUnavailableView {
                        Label("No Exercise Groups", systemImage: "dumbbell")
                    } description: {
                        Text("Tap + to create your first exercise group.")
                    }
                }
            }
            .confirmationDialog(
                "Delete \(groupToDelete?.name ?? "Group")?",
                isPresented: $groupToDelete.isPresent(),
                titleVisibility: .visible
            ) {
                Button("Delete", role: .destructive) {
                    if let group = groupToDelete {
                        modelContext.delete(group)
                        UIImpactFeedbackGenerator(style: .medium).impactOccurred()
                    }
                    groupToDelete = nil
                }
            } message: {
                Text("This will also delete all exercises in this group.")
            }
        }
    }

    private func confirmDeleteGroup(at offsets: IndexSet) {
        if let index = offsets.first {
            groupToDelete = groups[index]
        }
    }
}

/// Row displaying a group's color accent and name with exercise count
private struct GroupRow: View {
    let group: ExerciseGroup

    var body: some View {
        HStack(spacing: 12) {
            RoundedRectangle(cornerRadius: 4)
                .fill(Color(hex: group.color))
                .frame(width: 4, height: 32)

            VStack(alignment: .leading, spacing: 2) {
                Text(group.name)
                    .font(.headline)
                Text("\(group.exercises.count) exercises")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
        }
    }
}
