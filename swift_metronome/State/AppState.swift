import Foundation
import SwiftData

@Observable
class AppState {

    enum AccentPattern: Int, CaseIterable, Identifiable {
        case none
        case four
        case five
        case six
        case seven

        var id: Int { rawValue }
    }

    var activeSetlist: Setlist?

    // Selection (THIS is what SettingsView modifies)
    var selectedAccentPattern: AccentPattern = .four

    // Pattern definitions
    let noAccentPattern = [false]
    let fourAccentPattern  = [true, false, false, false]
    let fiveAccentPattern  = [true, false, false, false, false]
    let sixAccentPattern   = [true, false, false, false, false, false]
    let sevenAccentPattern = [true, false, false, false, false, false, false]

    // Read-only computed pattern used by the metronome
    var activeAccentPattern: [Bool] {
        switch selectedAccentPattern {
        case .none:  noAccentPattern
        case .four:  fourAccentPattern
        case .five:  fiveAccentPattern
        case .six:   sixAccentPattern
        case .seven: sevenAccentPattern
        }
    }
    
    func pattern(for pattern: AccentPattern) -> [Bool] {
        switch pattern {
        case .none:  noAccentPattern
        case .four:  fourAccentPattern
        case .five:  fiveAccentPattern
        case .six:   sixAccentPattern
        case .seven: sevenAccentPattern
        }
    }
}
