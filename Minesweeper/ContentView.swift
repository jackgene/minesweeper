//
//  ContentView.swift
//  Minesweeper
//
//  Created by Jack Leow on 2/18/24.
//

import SwiftUI

struct ContentView: View {
    @ObservedObject
    private var appState: AppState
    
    init(appState: AppState) {
        self.appState = appState
    }
    
    var body: some View {
        VStack(spacing: 20) {
            Grid {
                ForEach(
                    Array(appState.cells.enumerated()), id: \.offset
                ) { (top: Int, labels: [String?]) in
                    
                    GridRow {
                        ForEach(
                            Array(labels.enumerated()), id: \.offset
                        ) { (left: Int, label: String?) in
                            
                            Button(
                                action: {
                                    appState.inputs = .visit(
                                        position: Point(
                                            left: UInt(left),
                                            top: UInt(top)
                                        )
                                    )
                                }
                            ) {
                                Text(label ?? "")
                                    .font(.title)
                                    .frame(width: 20, height: 30)
                            }
                            .disabled(label != nil)
                            .focusable(false)
                        }
                    }
                    .padding(-3)
                }
            }
            
            Button(
                action: {
                    appState.inputs = .startOver(level: defaultLevel)
                }
            ) {
                Text("New Game").font(.title2)
            }
            .disabled(!appState.resetable)
        }
        .padding()
    }
}

#Preview {
    ContentView(appState: AppState())
}
