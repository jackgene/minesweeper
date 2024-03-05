//
//  Cell.swift
//  Minesweeper
//
//  Created by Jack Leow on 2/18/24.
//

import Foundation

enum Cell: Codable {
    case empty(adjacentMines: Int)
    case mine
}
extension Array where Element == Array<Cell> {
    var size: Size {
        if let row: [Cell] = first {
            Size(width: UInt(row.count), height: UInt(count))
        } else {
            Size(width: 0, height: 0)
        }
    }
}
