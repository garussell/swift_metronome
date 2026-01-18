import Foundation
import SwiftData

@Observable
class AppState {

    // MARK: - Accent Pattern Selection

    enum AccentPattern: Int, CaseIterable, Identifiable {
        case none
        case two
        case three
        case four
        case five
        case six
        case seven

        var id: Int { rawValue }

        var displayName: String {
            switch self {
            case .none:  "No Accent"
            case .two:   "2/4"
            case .three: "3/4"
            case .four:  "4/4"
            case .five:  "5/4"
            case .six:   "6/4"
            case .seven: "7/4"
            }
        }
    }

    // MARK: - Click Sound Selection

    enum ClickSound: Int, CaseIterable, Identifiable {
        case classic
        case soft
        case sharp

        var id: Int { rawValue }

        var displayName: String {
            switch self {
            case .classic: "Classic"
            case .soft:    "Soft"
            case .sharp:   "Sharp"
            }
        }
    }

    // MARK: - Global State

    var activeSetlist: Setlist?

    /// Accent pattern selected in Settings
    var selectedAccentPattern: AccentPattern = .four

    /// Click sound selected in Settings
    var selectedClickSound: ClickSound = .classic

    // MARK: - Accent Pattern Definitions

    private let noAccentPattern    = [false]
    private let twoAccentPattern   = [true, false]
    private let threeAccentPattern = [true, false, false]
    private let fourAccentPattern  = [true, false, false, false]
    private let fiveAccentPattern  = [true, false, false, false, false]
    private let sixAccentPattern   = [true, false, false, false, false, false]
    private let sevenAccentPattern = [true, false, false, false, false, false, false]

    // MARK: - Active Accent Pattern (used by Metronome)

    var activeAccentPattern: [Bool] {
        pattern(for: selectedAccentPattern)
    }

    // MARK: - Helpers

    func pattern(for pattern: AccentPattern) -> [Bool] {
        switch pattern {
        case .none:  noAccentPattern
        case .two:   twoAccentPattern
        case .three: threeAccentPattern
        case .four:  fourAccentPattern
        case .five:  fiveAccentPattern
        case .six:   sixAccentPattern
        case .seven: sevenAccentPattern
        }
    }
}

extension AppState.ClickSound {
    var synthStyle: SynthMetronome.ClickStyle {
        switch self {
        case .classic: .classic
        case .soft:    .soft
        case .sharp:   .sharp
        }
    }
}
