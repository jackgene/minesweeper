//
//  Position.swift
//  Minesweeper
//
//  Created by Jack Leow on 2/19/24.
//

import Foundation

struct Point: Equatable, Hashable {
    let left: UInt
    let top: UInt
    
    func adjacentPoints(withinWorldOfSize size: Size) -> [Point] {
        guard left < size.width, top < size.height else {
            return []
        }
        
        let adjLeftFrom: UInt = left > 0 ? left - 1 : 0
        let adjLeftTo: UInt = left < size.width ? left + 1 : size.width
        let adjTopFrom: UInt = top > 0 ? top - 1 : 0
        let adjTopTo: UInt = top < size.height ? top + 1 : size.height
        
        return (adjLeftFrom..<adjLeftTo).flatMap { (adjLeft: UInt) in
            (adjTopFrom..<adjTopTo).compactMap { (adjTop: UInt) in
                if top != adjTop && left != adjLeft {
                    Point(left: adjLeft, top: adjTop)
                } else {
                    nil
                }
            }
        }
    }
}
