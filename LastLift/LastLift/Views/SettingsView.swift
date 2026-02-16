import SwiftUI

/// Settings sheet for user preferences
struct SettingsView: View {
    @Environment(\.dismiss) private var dismiss
    @AppStorage("dateFormat") private var dateFormat: DateFormatSetting = .relative

    var body: some View {
        NavigationStack {
            Form {
                Section("Date Display") {
                    Picker("Format", selection: $dateFormat) {
                        ForEach(DateFormatSetting.allCases, id: \.self) { setting in
                            Text(setting.label).tag(setting)
                        }
                    }
                    .pickerStyle(.inline)
                    .labelsHidden()
                }
            }
            .navigationTitle("Settings")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Done") { dismiss() }
                }
            }
        }
    }
}
