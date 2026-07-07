import SwiftUI

/// Squareup palette: mint-green jar glass + warm copper coins.
/// Distinct from every prior app's palette (no cream/ink, no charcoal/volt, no navy/coral).
enum Theme {
    static let mint = Color(red: 0.75, green: 0.93, blue: 0.85)
    static let mintDeep = Color(red: 0.20, green: 0.55, blue: 0.42)
    static let jarGlass = Color(red: 0.90, green: 0.97, blue: 0.94)
    static let copper = Color(red: 0.72, green: 0.42, blue: 0.24)
    static let copperBright = Color(red: 0.85, green: 0.53, blue: 0.30)
    static let ink = Color(red: 0.12, green: 0.16, blue: 0.14)
    static let background = Color(red: 0.96, green: 0.98, blue: 0.97)
    static let cardBackground = Color.white

    static let titleFont = Font.system(size: 28, weight: .bold, design: .rounded)
    static let bodyFont = Font.system(size: 17, weight: .regular, design: .rounded)
    static let numberFont = Font.system(size: 44, weight: .heavy, design: .rounded)
}

extension View {
    /// Real tap-anywhere keyboard dismiss (scroll alone is not sufficient).
    func dismissKeyboardOnTap() -> some View {
        simultaneousGesture(TapGesture().onEnded {
            UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
        })
    }
}
