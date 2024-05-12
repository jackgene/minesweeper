//
//  MineField.swift
//  Minesweeper
//
//  Created by Jack Leow on 2/18/24.
//

import Foundation

public enum MineField {
    case uninitialized(level: Level)
    case sweeping(cells: [[Cell]], remaining: Set<Point>)
    case tripped(cells: [[Cell]], mine: Point)
    case swept(cells: [[Cell]])
    
    public var cellLabels: [[String?]] {
        switch self {
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
}
extension MineField: Codable {
    private static let jsonDecoder: JSONDecoder = JSONDecoder()
    private static let jsonEncoder: JSONEncoder = JSONEncoder()

    public static func from(json: Data) throws -> MineField {
        try jsonDecoder.decode(MineField.self, from: json)
    }
    
    public var json: Data {
        get throws {
            try Self.jsonEncoder.encode(self)
        }
    }
}
