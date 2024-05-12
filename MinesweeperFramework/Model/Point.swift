//
//  Position.swift
//  Minesweeper
//
//  Created by Jack Leow on 2/19/24.
//

import Foundation

public struct Point: Equatable, Hashable, Codable {
    let left: UInt
    let top: UInt
    
    public init(left: UInt, top: UInt) {
        self.left = left
        self.top = top
    }
    
    func adjacentPoints(withinWorldOfSize size: Size) -> [Point] {
        guard left < size.width, top < size.height else {
            return []
        }
        
        let maxLeft: UInt = size.width + 1
        let maxTop: UInt = size.height + 1
        let adjLeftFrom: UInt = left > 0 ? left - 1 : 0
        let adjLeftTo: UInt = left < maxLeft ? left + 1 : maxLeft
        let adjTopFrom: UInt = top > 0 ? top - 1 : 0
        let adjTopTo: UInt = top < maxTop ? top + 1 : maxTop
        
        return (adjLeftFrom...adjLeftTo).flatMap { (adjLeft: UInt) in
            (adjTopFrom...adjTopTo).compactMap { (adjTop: UInt) in
                if top == adjTop && left == adjLeft {
                    nil
                } else {
                    Point(left: adjLeft, top: adjTop)
                }
            }
        }
    }
}
