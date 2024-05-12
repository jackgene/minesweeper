//
//  Size.swift
//  Minesweeper
//
//  Created by Jack Leow on 2/19/24.
//

import Foundation

public struct Size: Equatable, Codable {
    public let width: UInt
    public let height: UInt
    
    public init(width: UInt, height: UInt) {
        self.width = width
        self.height = height
    }
}
