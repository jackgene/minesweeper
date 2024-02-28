//
//  Level.swift
//  Minesweeper
//
//  Created by Jack Leow on 2/24/24.
//

struct Level {
    static let beginner: Level = Level(
        size: Size(width: 9, height: 9), mines: 10
    )
    static let intermediate: Level = Level(
        size: Size(width: 16, height: 16), mines: 40
    )
    static let advanced: Level = Level(
        size: Size(width: 30, height: 16), mines: 99
    )
    
    let size: Size // TODO validate non-zero
    let mines: UInt
}
