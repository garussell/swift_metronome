import Foundation
import SwiftData

@Model
final class Tempo {
    @Attribute(.unique) var id: UUID = UUID()
    var name: String
    var bpm: Int
    var setlist: Setlist?

    var order: Int   // song position

    init(name: String, bpm: Int, setlist: Setlist?, order: Int) {
        self.name = name
        self.bpm = bpm
        self.setlist = setlist
        self.order = order
    }
}



