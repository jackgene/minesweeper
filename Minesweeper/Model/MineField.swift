//
//  MineField.swift
//  Minesweeper
//
//  Created by Jack Leow on 2/18/24.
//

import Foundation

enum MineField {
    case uninitialized(level: Level)
    case sweeping(cells: [[Cell]], remaining: Set<Point>)
    case tripped(cells: [[Cell]], mine: Point)
    case swept(cells: [[Cell]])
}
