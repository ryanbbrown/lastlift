import SwiftUI

/// Grid of preset color swatches for selecting an exercise group color
struct ColorPickerField: View {
    @Binding var selectedColor: String

    private let colors: [(name: String, hex: String)] = [
        ("Purple", "#9333ea"),
        ("Blue", "#2563eb"),
        ("Green", "#10b981"),
        ("Red", "#ef4444"),
        ("Orange", "#f97316"),
        ("Pink", "#ec4899"),
    ]

    var body: some View {
        LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 12), count: 3), spacing: 12) {
            ForEach(colors, id: \.hex) { color in
                Button {
                    selectedColor = color.hex
                } label: {
                    RoundedRectangle(cornerRadius: 8)
                        .fill(Color(hex: color.hex))
                        .frame(height: 44)
                        .overlay {
                            if selectedColor == color.hex {
                                Image(systemName: "checkmark")
                                    .font(.headline)
                                    .bold()
                                    .foregroundStyle(.white)
                            }
                        }
                }
                .accessibilityIdentifier("color-swatch-\(color.name.lowercased())")
                .accessibilityLabel(color.name)
            }
        }
    }
}
