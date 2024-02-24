//
//  Cell.swift
//  Minesweeper
//
//  Created by Jack Leow on 2/18/24.
//

import Foundation

enum Cell {
    case empty(adjacentMines: Int)
    case mine
}
