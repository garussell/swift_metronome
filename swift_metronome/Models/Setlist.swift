import SwiftUI
import SwiftData

// Models/Setlist.swift
@Model
final class Setlist {
    var name: String
    init(name: String) { self.name = name }
}
