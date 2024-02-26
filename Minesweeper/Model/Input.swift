//
//  Input.swift
//  Minesweeper
//
//  Created by Jack Leow on 2/20/24.
//

enum Input {
    case visit(position: Point)
    case startOver(level: Level)
    
    private func expandVisitIfSafeTo(
        _ visitedPoint: Point, _ remaining: Set<Point>, _ cells: [[Cell]]
    ) -> Set<Point> {
        guard
            case .empty(0) = cells[Int(visitedPoint.top)][Int(visitedPoint.left)]
        else {
            return remaining
        }

        let adjacentPoints: [Point] = visitedPoint
            .adjacentPoints(withinWorldOfSize: cells.size)
            .filter(remaining.contains)
        return adjacentPoints
            .reduce(
                remaining.subtracting(adjacentPoints)
            ) { (nextRemaining: Set<Point>, adjPoint: Point) in
                expandVisitIfSafeTo(adjPoint, nextRemaining, cells)
            }
    }
    
    func update(mineField: MineField) -> MineField {
        switch self {
        case .startOver(let level):
            return .uninitialized(level: level)
            
        case .visit(let visitedPoint):
            switch mineField {
            case .uninitialized(let level):
                let availablePositions: [Point] = (0..<level.size.height)
                    .flatMap { (top: UInt) in
                        (0..<level.size.width).compactMap { (left: UInt) in
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
                let cells: [[Cell]] = (0..<level.size.height).map { (top: UInt) in
                    (0..<level.size.width).map { (left: UInt) in
                        if mines.contains(Point(left: left, top: top)) {
                            .mine
                        } else {
                            .empty(
                                adjacentMines: Point(left: left, top: top)
                                    .adjacentPoints(withinWorldOfSize: level.size)
                                    .filter(mines.contains)
                                    .count
                            )
                        }
                    }
                }
                
                return .sweeping(
                    cells: cells,
                    remaining: expandVisitIfSafeTo(visitedPoint, remaining, cells)
                )
                
            case .sweeping(let cells, let currentRemaining):
                let visitedTop: Int = Int(visitedPoint.top)
                let visitedLeft: Int = Int(visitedPoint.left)
                var nextRemaining: Set<Point> = currentRemaining
                
                if let _ = nextRemaining.remove(visitedPoint) {
                    if nextRemaining.isEmpty {
                        return .swept(cells: cells)
                    } else {
                        return .sweeping(
                            cells: cells,
                            remaining: expandVisitIfSafeTo(
                                visitedPoint, nextRemaining, cells
                            )
                        )
                    }
                } else {
                    if case .mine = cells[visitedTop][visitedLeft] {
                        return .tripped(cells: cells, mine: visitedPoint)
                    } else {
                        // This could happen when a buggy UI allows
                        // a cell to be visited more than once.
                        return mineField
                    }
                }
                
            case .swept(_), .tripped(_, _):
                return mineField
            }
        }
    }
}
