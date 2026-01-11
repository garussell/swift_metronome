import Foundation
import SwiftData

@Model
final class Tempo {
    var name: String
    var bpm: Int
    var setlist: Setlist?      // <-- relationship

    init(name: String, bpm: Int, setlist: Setlist? = nil) {
        self.name = name
        self.bpm = bpm
        self.setlist = setlist
    }
}



