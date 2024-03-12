//
//  AppIntents.swift
//  MinesweeperWidgetExtension
//
//  Created by Jack Leow on 3/10/24.
//

import AppIntents
import SwiftUI

let mineFieldJSONKey: String = "mineFieldJSON"

struct StartOverIntent: AppIntent {
    static var title: LocalizedStringResource = "Start Over"
    
    func perform() async throws -> some IntentResult {
        UserDefaults.standard.setValue(Data(), forKey: mineFieldJSONKey)
        
        return .result()
    }
}

struct VisitCellIntent: AppIntent {
    static var title: LocalizedStringResource = "Visit Cell"
    
    @Parameter(title: "top")
    var top: Int
    
    @Parameter(title: "left")
    var left: Int
    
    init(top: Int, left: Int) {
        self.top = top
        self.left = left
    }
    
    init() {
        self.top = 4
        self.left = 4
    }
    
    func perform() async throws -> some IntentResult {
        let store: UserDefaults = .standard
        if let mineFieldJSON: Data = store.data(forKey: mineFieldJSONKey) {
            let lastMineField: MineField = (
                try? .from(json: mineFieldJSON)
            ) ?? .uninitialized(level: .beginner)
            let nextMineField: MineField = Input
                .visit(position: Point(left: UInt(left), top: UInt(top)))
                .update(mineField: lastMineField)
            
            if let nextMineFieldJSON: Data = try? nextMineField.json {
                store.setValue(nextMineFieldJSON, forKey: mineFieldJSONKey)
            }
        }
        
        return .result()
    }
}
