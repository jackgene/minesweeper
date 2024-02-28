//
//  MinesweeperApp.swift
//  Minesweeper
//
//  Created by Jack Leow on 2/18/24.
//

import SwiftUI

@objc
class AppDelegate: NSObject, NSApplicationDelegate {
    var token: NSKeyValueObservation?
    
    func applicationShouldTerminateAfterLastWindowClosed(
        _ sender: NSApplication
    ) -> Bool {
        return true
    }
}

@main
struct MinesweeperApp: App {
    @StateObject
    private var appState: AppState = AppState()
    @NSApplicationDelegateAdaptor(AppDelegate.self)
    private var appDelegate: AppDelegate
    
    var body: some Scene {
        WindowGroup {
            ContentView(appState: appState)
        }
        .commandsRemoved()
        .commands {
            CommandMenu("Game") {
                Button("New") {
                    appState.inputs = .startOver(level: defaultLevel)
                }
                .keyboardShortcut("N")
                .disabled(!appState.resetable)
            }
        }
        .windowResizability(.contentSize)
    }
}
