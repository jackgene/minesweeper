//
//  ContentView.swift
//  Minesweeper
//
//  Created by Jack Leow on 2/18/24.
//

import Combine
import SwiftUI

fileprivate let defaultLevel: Level = Level(
    size: Size(width: 9, height: 9), mines: 10
)

class ViewModel: ObservableObject {
    @Published var inputs: Input = .startOver(level: defaultLevel)
    @Published var cells: [[String?]] = []
    
    init() {
        let mineFields: some Publisher<MineField, Never> = $inputs
            .scan(.uninitialized(level: defaultLevel)) { (lastMineField: MineField, input: Input) in
                let nextMineField: MineField = input.update(mineField: lastMineField)
                return nextMineField
            }
            .share()
        
        mineFields
            .map {
                switch $0 {
                case .uninitialized(level: let level):
                    (0..<level.size.height).map { _ in
                        (0..<level.size.width).map { _ in
                            nil
                        }
                    }
                    
                case .sweeping(cells: let cells, remaining: let remaining):
                    cells.enumerated().map { (top: Int, cells: [Cell]) in
                        cells.enumerated().map { (left: Int, cell: Cell) in
                            if remaining.contains(Point(left: UInt(left), top: UInt(top))) {
                                nil
                            } else {
                                switch cell {
                                case .empty(adjacentMines: let count):
                                    count > 0 ? "\(count)" : ""
                                case .mine:
                                    nil
                                }
                            }
                        }
                    }
                    
                case .tripped(cells: let cells, mine: let mine):
                    cells.enumerated().map { (top: Int, cells: [Cell]) in
                        cells.enumerated().map { (left: Int, cell: Cell) in
                            switch cell {
                            case .empty(adjacentMines: let count):
                                count > 0 ? "\(count)" : ""
                            case .mine:
                                if Point(left: UInt(left), top: UInt(top)) == mine {
                                    "💥"
                                } else {
                                    "💣"
                                }
                            }
                        }
                    }

                case .swept(cells: let cells):
                    cells.map { (cells: [Cell]) in
                        cells.map { (cell: Cell) in
                            switch cell {
                            case .empty(adjacentMines: let count):
                                count > 0 ? "\(count)" : ""
                            case .mine:
                                "🚩"
                            }
                        }
                    }
                }
            }
            .assign(to: &$cells)
//        mineFields
//            .map {
//                return switch $0 {
//                case .uninitialized(level: let level):
//                    level.size
//                case .sweeping(cells: let cells, _),
//                        .tripped(cells: let cells, _),
//                        .swept(cells: let cells):
//                    cells.size
//                }
//            }
//            .removeDuplicates { $0 != $1 }
//            .map { (size: Size) in
//                (0..<Int(size.height)).map { (row: Int) in
//                    (0..<Int(size.width)).map { (col: Int) in
//                        mineFields.map {
//                            switch $0 {
//                            case .uninitialized(_):
//                                nil
//                            case .sweeping(cells: _, remaining: _):
//                                "!"
//                            case .tripped(cells: _, mine: _):
//                                "💥"
//                            case .swept(cells: _):
//                                "🧹"
//                            }
//                        }
//                    }
//                }
//            }
//            .assign(to: &$cells)
    }
}

struct ContentView: View {
    @StateObject var viewModel: ViewModel = ViewModel()
    
    var body: some View {
        VStack {
            Grid {
                ForEach(
                    Array(viewModel.cells.enumerated()), id: \.offset
                ) { (top: Int, labels: [String?]) in
                    
                    GridRow {
                        ForEach(
                            Array(labels.enumerated()), id: \.offset
                        ) { (left: Int, label: String?) in
                            
                            Button(
                                action: {
                                    viewModel.inputs = .visit(
                                        position: Point(
                                            left: UInt(left),
                                            top: UInt(top)
                                        )
                                    )
                                },
                                label: { Text(label ?? "") }
                            )
                            .disabled(label != nil)
                        }
                    }
                }
            }
            Button(
                action: {
                    viewModel.inputs = .startOver(level: defaultLevel)
                },
                label: {
                    Text("New Game")
                }
            )
        }
        .padding()
    }
}

#Preview {
    ContentView()
}
