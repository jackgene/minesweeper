//
//  AppIntents.swift
//  MinesweeperWidgetExtension
//
//  Created by Jack Leow on 3/10/24.
//

import AppIntents
import MinesweeperFramework
import SwiftUI

public let store: UserDefaults = UserDefaults(
    suiteName: Bundle.main
        .infoDictionary!["NSExtensionFileProviderDocumentGroup"] as? String
)!
public let mineFieldJSONKey: String = "mineFieldJSON"

public struct StartOverIntent: AppIntent {
    public static var title: LocalizedStringResource = "Start Over"
    
    public init() {}
    
    public func perform() async throws -> some IntentResult {
        store.setValue(Data(), forKey: mineFieldJSONKey)
        
        return .result()
    }
}

public struct VisitCellIntent: AppIntent {
    public static var title: LocalizedStringResource = "Visit Cell"
    
    @Parameter(title: "top")
    var top: Int
    
    @Parameter(title: "left")
    var left: Int
    
    public init(top: Int, left: Int) {
        self.top = top
        self.left = left
    }
    
    public init() {
        self.top = 4
        self.left = 4
    }
    
    public func perform() async throws -> some IntentResult {
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
