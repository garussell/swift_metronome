import Foundation
import SwiftData

@Model
final class Tempo {
    @Attribute(.unique) var id: UUID = UUID()
    var name: String
    var bpm: Int

    init(name: String, bpm: Int) {
        self.name = name
        self.bpm = bpm
    }
}
