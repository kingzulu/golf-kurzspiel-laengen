import SwiftUI

struct Club: Identifiable, Codable, Equatable {
    var id = UUID()
    var name: String
    var v730: Double?
    var v900: Double?
    var v1100: Double?
    // Längen mit geöffnetem Schlägerblatt
    var o730: Double?
    var o900: Double?
    var o1100: Double?

    var hasName: Bool {
        !name.trimmingCharacters(in: .whitespaces).isEmpty
    }
}

/// Wie weit ausgeholt wird, gedacht als Uhrzeiger.
enum Swing: Int, CaseIterable, Identifiable {
    case h730 = 0, h900, h1100

    var id: Int { rawValue }

    var label: String {
        switch self {
        case .h730: return "7:30"
        case .h900: return "9:00"
        case .h1100: return "11:00"
        }
    }

    /// Winkel des Zeigers, 12 Uhr = 0°, im Uhrzeigersinn.
    var degrees: Double {
        switch self {
        case .h730: return 225
        case .h900: return 270
        case .h1100: return 330
        }
    }

    func keyPath(_ face: Face) -> WritableKeyPath<Club, Double?> {
        switch (self, face) {
        case (.h730, .square): return \.v730
        case (.h900, .square): return \.v900
        case (.h1100, .square): return \.v1100
        case (.h730, .open): return \.o730
        case (.h900, .open): return \.o900
        case (.h1100, .open): return \.o1100
        }
    }
}

/// Normales oder geöffnetes Schlägerblatt.
enum Face: CaseIterable, Identifiable {
    case square, open

    var id: Self { self }

    var title: String {
        switch self {
        case .square: return "Normal"
        case .open: return "Offenes Schlägerblatt"
        }
    }
}

enum Meters {
    static func text(_ value: Double) -> String {
        value.formatted(.number.precision(.fractionLength(0...1)))
    }

    /// Akzeptiert "25,5" und "25.5". Leer oder ungültig ergibt nil.
    static func parse(_ text: String) -> Double? {
        let cleaned = text.trimmingCharacters(in: .whitespaces).replacingOccurrences(of: ",", with: ".")
        guard let value = Double(cleaned), value >= 0, value < 1000 else { return nil }
        return value
    }
}
