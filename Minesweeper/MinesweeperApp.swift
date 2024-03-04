//
//  MinesweeperApp.swift
//  Minesweeper
//
//  Created by Jack Leow on 2/18/24.
//

import SwiftUI

@main
struct MinesweeperApp: App {
    @StateObject
    private var appState: AppState = AppState()
    
    var body: some Scene {
        Window("Minesweeper", id: "main") {
            ContentView(appState: appState)
        }
        .commandsRemoved()
        .commands {
            CommandMenu("Game") {
                Button("New") {
                    appState.input.send(.startOver)
                }
                .keyboardShortcut("N")
                .disabled(!appState.resetable)
                
                Menu("Difficulty") {
                    Button("Beginner") {
                        appState.input.send(.changeLevel(level: .beginner))
                    }
                    .keyboardShortcut("1")
                    
                    Button("Intermediate") {
                        appState.input.send(.changeLevel(level: .intermediate))
                    }
                    .keyboardShortcut("2")
                    
                    Button("Advanced") {
                        appState.input.send(.changeLevel(level: .advanced))
                    }
                    .keyboardShortcut("3")
                }
            }
        }
        .windowResizability(.contentSize)
    }
}
