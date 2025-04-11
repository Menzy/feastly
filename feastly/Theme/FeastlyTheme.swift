import SwiftUI

struct FeastlyTheme {
    // Colors
    static let primary = Color.orange
    static let secondary = Color(hex: "FF9F5A")
    static let background = Color(hex: "FFFAF5")
    static let textPrimary = Color.black
    static let textSecondary = Color.gray
    
    // Text Styles
    static let titleFont = Font.system(size: 28, weight: .bold)
    static let headlineFont = Font.system(size: 20, weight: .semibold)
    static let bodyFont = Font.system(size: 16, weight: .regular)
    static let captionFont = Font.system(size: 14, weight: .regular)
    
    // Button Styles
    static func primaryButton(_ content: String) -> some View {
        Text(content)
            .font(.headline)
            .foregroundColor(.white)
            .frame(maxWidth: .infinity)
            .padding()
            .background(
                RoundedRectangle(cornerRadius: 30)
                    .fill(primary)
            )
            .padding(.horizontal, 20)
    }
    
    static func secondaryButton(_ content: String) -> some View {
        Text(content)
            .foregroundColor(primary)
            .padding()
            .background(
                RoundedRectangle(cornerRadius: 30)
                    .stroke(primary, lineWidth: 2)
            )
            .padding(.horizontal, 20)
    }
}

// Extension to create colors from hex values
extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3: // RGB (12-bit)
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6: // RGB (24-bit)
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8: // ARGB (32-bit)
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (255, 0, 0, 0)
        }
        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue: Double(b) / 255,
            opacity: Double(a) / 255
        )
    }
}
