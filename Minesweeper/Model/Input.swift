//
//  Input.swift
//  Minesweeper
//
//  Created by Jack Leow on 2/20/24.
//

enum Input {
    case visit(position: Point)
    case startOver(level: Level)
    
    func update(mineField: MineField) -> MineField {
        switch self {
        case .startOver(let level):
            return .uninitialized(level: level)
            
        case .visit(let visitedPoint):
            switch mineField {
            case .uninitialized(let level):
                let maxLeft: UInt = level.size.width - 1
                let maxTop: UInt = level.size.height - 1
                let availablePositions: [Point] = (0...maxTop)
                    .flatMap { (top: UInt) in
                        (0...maxLeft).compactMap { (left: UInt) in
                            if visitedPoint.left == left && visitedPoint.top == top {
                                nil // First visited position is never navailable
                            } else {
                                Point(left: left, top: top)
                            }
                        }
                    }
                    .shuffled()
                let mineCount: Int = Int(level.mines)
                let mines: Set<Point> = Set(
                    availablePositions.prefix(mineCount)
                )
                let remaining: Set<Point> = Set(
                    availablePositions.dropFirst(mineCount)
                )
                
                return .sweeping(
                    cells: (0...maxTop).map { (top: UInt) in
                        (0...maxLeft).map { (left: UInt) in
                            if mines.contains(Point(left: left, top: top)) {
                                .mine
                            } else {
                                .empty(
                                    adjacentMines: (max(0, top - 1)...min(maxTop, top + 1))
                                        .flatMap { (adjTop: UInt) in
                                            (max(0, left - 1)...min(maxLeft, left + 1))
                                                .compactMap { (adjLeft: UInt) in
                                                    if mines.contains(
                                                        Point(left: adjLeft, top: adjTop)
                                                    ) {
                                                        1
                                                    } else {
                                                        0
                                                    }
                                                }
                                        }
                                        .reduce(0) { $0 + $1 }
                                )
                            }
                        }
                    },
                    remaining: remaining
                )
                
            case .sweeping(let cells, let currentRemaining):
                var nextRemaining: Set<Point> = currentRemaining
                if let removed: Point = nextRemaining.remove(visitedPoint) {
                    if nextRemaining.isEmpty {
                        return .swept(cells: cells)
                    } else {
                        return .sweeping(cells: cells, remaining: nextRemaining)
                    }
                } else {
                    let visitedTop: Int = Int(visitedPoint.top)
                    let visitedLeft: Int = Int(visitedPoint.left)
                    if case .mine = cells[visitedTop][visitedLeft] {
                        return .tripped(
                            cells: cells, mine: visitedPoint, remaining: currentRemaining
                        )
                    } else {
                        // This could happen in cases where a buggy UI
                        // allows a cell to be visited more than once
                        return mineField
                    }
                }
                
            case .swept(_), .tripped(_, _, _):
                return mineField
            }
        }
    }
}
