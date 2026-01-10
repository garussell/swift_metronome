//
//  Item.swift
//  swift_metronome
//
//  Created by Allen Russell on 12/29/25.
//

import Foundation
import SwiftData

@Model
final class Item {
    var timestamp: Date
    
    init(timestamp: Date) {
        self.timestamp = timestamp
    }
}
