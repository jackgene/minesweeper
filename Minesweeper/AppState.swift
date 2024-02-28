//
//  AppState.swift
//  Minesweeper
//
//  Created by Jack Leow on 2/27/24.
//

import Combine

class AppState: ObservableObject {
    @Published var inputs: Input = .startOver
    @Published var cells: [[String?]] = []
    @Published var resetable: Bool = false
    
    init() {
        let mineFields: some Publisher<MineField, Never> = $inputs
            .scan(.uninitialized(level: .beginner)) { (lastMineField: MineField, input: Input) in
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
        
        mineFields
            .map {
                switch $0 {
                case .uninitialized(_): false
                case .sweeping(_, _), .tripped(_, _), .swept(_): true
                }
            }
            .assign(to: &$resetable)
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

