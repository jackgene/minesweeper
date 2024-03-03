//
//  ContentView.swift
//  Minesweeper
//
//  Created by Jack Leow on 2/18/24.
//

import SwiftUI

struct CellView: View {
    private let position: Point
    private let app: AppState
    @ObservedObject
    private var cellState: CellState
    
    init(position: Point, app: AppState, cellState: CellState) {
        self.position = position
        self.app = app
        self.cellState = cellState
    }
    
    var body: some View {
        Button(
            action: {
                app.input.send(.visit(position: position))
            }
        ) {
            Text(cellState.label ?? "")
                .font(.title)
                .frame(width: 20, height: 30)
        }
        .disabled(cellState.label != nil)
        .focusable(false)
        .padding(-3.5)
    }
}

struct ContentView: View {
    @ObservedObject
    private var appState: AppState
    
    init(appState: AppState) {
        self.appState = appState
    }
    
    var body: some View {
        VStack(spacing: 20) {
            ForEach(
                0..<appState.size.height, id: \.self
            ) { (top: UInt) in
                
                HStack {
                    ForEach(
                        0..<appState.size.width, id: \.self
                    ) { (left: UInt) in
                        CellView(
                            position: Point(left: left, top: top),
                            app: appState, cellState: appState.cells[Int(top)][Int(left)]
                        )
                    }
                }
                .padding(-6)
            }
            
            Button(
                action: {
                    appState.input.send(.startOver)
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
