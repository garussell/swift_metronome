import SwiftUI
import SwiftData

// Models/Setlist.swift
@Model
final class Setlist {
    var name: String
    var tempos: [Tempo] = []   // <-- relationship

    init(name: String) {
        self.name = name
    }
}


