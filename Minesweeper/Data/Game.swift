//
//  Game.swift
//  Minesweeper
//
//  Created by Jack Leow on 3/4/24.
//

import Foundation
import SwiftData

@Model
final class Game {
    // This will only ever be true, and serves to ensure there is
    // no more than a single persisted game instance.
    //
    // Void is ideal here, instead of Bool. But SwiftData does not support Void.
    // Attempting to use a Codable enum with a single value results in:
    //  "Property type is not valid for unique constraints."
    @Attribute(.unique) private let unique: Bool
    var mineFieldJSON: Data
    
    init(mineFieldJSON: Data) {
        self.unique = true
        self.mineFieldJSON = mineFieldJSON
    }
}
