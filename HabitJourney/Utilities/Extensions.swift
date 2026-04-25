import SwiftUI
import Foundation

// MARK: - App Color Palette

extension Color {
    static let hjBackground   = Color(red: 0.06, green: 0.06, blue: 0.10)
    static let hjSurface      = Color(red: 0.12, green: 0.12, blue: 0.18)
    static let hjSurface2     = Color(red: 0.17, green: 0.17, blue: 0.25)
    static let hjPrimary      = Color(red: 0.42, green: 0.33, blue: 0.95)
    static let hjPrimaryLight = Color(red: 0.60, green: 0.52, blue: 1.00)
    static let hjGold         = Color(red: 0.96, green: 0.76, blue: 0.26)
    static let hjGreen        = Color(red: 0.27, green: 0.82, blue: 0.52)
    static let hjText         = Color(red: 0.95, green: 0.95, blue: 0.98)
    static let hjSubtext      = Color(red: 0.55, green: 0.55, blue: 0.65)
}

// MARK: - Date Helpers

extension Date {
    var isToday: Bool { Calendar.current.isDateInToday(self) }
    var isYesterday: Bool { Calendar.current.isDateInYesterday(self) }

    var relativeLabel: String {
        if isToday { return "Today" }
        if isYesterday { return "Yesterday" }
        let f = DateFormatter()
        f.dateStyle = .medium
        return f.string(from: self)
    }

    var shortWeekday: String {
        let f = DateFormatter()
        f.dateFormat = "EEE"
        return f.string(from: self)
    }

    var shortDate: String {
        let f = DateFormatter()
        f.dateFormat = "MMM d"
        return f.string(from: self)
    }

    var fullDate: String {
        let f = DateFormatter()
        f.dateFormat = "EEEE, MMMM d"
        return f.string(from: self)
    }
}

// MARK: - Int Helpers

extension Int {
    var toHoursMinutes: String {
        let h = self / 60
        let m = self % 60
        if h > 0 && m > 0 { return "\(h)h \(m)m" }
        if h > 0 { return "\(h)h" }
        return "\(m)m"
    }
}

// MARK: - View Modifiers

struct CardStyle: ViewModifier {
    func body(content: Content) -> some View {
        content
            .padding(16)
            .background(Color.hjSurface)
            .cornerRadius(16)
    }
}

extension View {
    func cardStyle() -> some View { modifier(CardStyle()) }

    func glowEffect(color: Color = .hjPrimary, radius: CGFloat = 8) -> some View {
        self.shadow(color: color.opacity(0.5), radius: radius, x: 0, y: 0)
    }
}

// MARK: - LinearGradient Helpers

extension LinearGradient {
    static var primaryGradient: LinearGradient {
        LinearGradient(
            colors: [Color(red: 0.42, green: 0.33, blue: 0.95), Color(red: 0.70, green: 0.33, blue: 0.95)],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    }

    static var goldGradient: LinearGradient {
        LinearGradient(
            colors: [Color(red: 1.00, green: 0.83, blue: 0.30), Color(red: 0.96, green: 0.60, blue: 0.20)],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    }

    static var greenGradient: LinearGradient {
        LinearGradient(
            colors: [Color(red: 0.27, green: 0.82, blue: 0.52), Color(red: 0.20, green: 0.70, blue: 0.60)],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    }
}
