//
//  Level.swift
//  Minesweeper
//
//  Created by Jack Leow on 2/24/24.
//

public struct Level: Codable {
    public static let beginner: Level = Level(
        size: Size(width: 9, height: 9), mines: 10
    )
    public static let intermediate: Level = Level(
        size: Size(width: 16, height: 16), mines: 40
    )
    public static let advanced: Level = Level(
        size: Size(width: 30, height: 16), mines: 99
    )
    
    public let size: Size // TODO validate non-zero
    let mines: UInt
}
