import SwiftUI

extension Binding {
    /// Creates a Boolean binding that is `true` when the optional value is non-nil, setting to `false` clears it
    func isPresent<T>() -> Binding<Bool> where Value == T? {
        Binding<Bool>(
            get: { wrappedValue != nil },
            set: { if !$0 { wrappedValue = nil } }
        )
    }
}
