//
//  ViewController.swift
//  Minesweeper
//
//  Created by Jack Leow on 11/26/20.
//  Copyright © 2020 Jack Leow. All rights reserved.
//

import Cocoa

class ViewController: NSViewController {
    static let cellSizePx = 24

    class Cell {
        let row: Int
        let col: Int
        let game: ViewController
        let button: NSButton
        var isVisited: Bool {
            get {
                return !button.isEnabled
            }
            set {
                if newValue == button.isEnabled {
                    self.button.isEnabled = !newValue
                }
            }
        }
        lazy var neighbors: Array<Cell> =
            game.cells[max(0, row - 1)..<min(game.cells.count, row + 2)]
                .flatMap({ $0[max(0, col - 1)..<min(game.cells[0].count, col + 2)] })
                .filter({ $0.row != self.row || $0.col != self.col })
        var isMine: Bool = false {
            didSet {
                if isMine {
                    for neighbor in neighbors {
                        neighbor.neighboringMineCount += 1
                    }
                }
            }
        }
        var neighboringMineCount: Int = 0

        init(row: Int, col: Int, game: ViewController) {
            self.row = row
            self.col = col
            self.game = game
            button = NSButton(
                frame: CGRect(
                    x: col * ViewController.cellSizePx, y: row * ViewController.cellSizePx - 1,
                    width: ViewController.cellSizePx, height: ViewController.cellSizePx + 2
                )
            )
            button.font = NSFont.boldSystemFont(ofSize: 0)
            button.title = ""
            button.bezelStyle = NSButton.BezelStyle.smallSquare
            button.target = self
            button.action = #selector(visit)
            game.view.addSubview(button)
        }

        func layMines(total: Int) {
            var mineAdded = 0
            
            while mineAdded < total {
                let row = Int.random(in: 0..<game.rowCount)
                let col = Int.random(in: 0..<game.colCount)
                
                if row != self.row && col != self.col && !game.cells[row][col].isMine {
                    game.cells[row][col].isMine = true
                    mineAdded += 1
                }
            }
            game.minesLaid = true
            game.cellsToVisit = game.rowCount * game.colCount - total
        }

        @objc func visit() {
            if game.cellsToVisit > 0 {
                button.isEnabled = false
                if !game.minesLaid {
                    layMines(total: game.minesCount)
                }
                if isMine {
                    if game.mineTripped {
                        button.title = "🔘"
                    } else {
                        button.title = "💥"
                    }
                    game.mineTripped = true
                    for row in game.cells {
                        for cell in row {
                            if cell.button.isEnabled {
                                cell.visit()
                            }
                        }
                    }
                } else {
                    if neighboringMineCount > 0 {
                        button.contentTintColor = NSColor.blue
                        button.title = "\(neighboringMineCount)"
                    } else {
                        for neighbor in neighbors {
                            if neighbor.button.isEnabled {
                                neighbor.visit()
                            }
                        }
                    }
                    if !game.mineTripped {
                        game.cellsToVisit -= 1
                        if game.cellsToVisit <= 0 {
                            for row in game.cells {
                                for cell in row {
                                    if cell.isMine {
                                        cell.button.title = "🚩"
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }
    }

    var colCount = 9
    var rowCount = 9
    var minesCount = 10
    var cells: Array<Array<Cell>> = Array(
        repeating: [],
        count: 9
    )
    var minesLaid: Bool = false
    var mineTripped: Bool = false
    var cellsToVisit: Int = Int.max

    override func viewDidLoad() {
        super.viewDidLoad()

        self.view.frame = CGRect(
            x: 20, y: 20,
            width: colCount * ViewController.cellSizePx,
            height: rowCount * ViewController.cellSizePx + 1
        )
        for row in 0..<rowCount {
            for col in 0..<colCount {
                cells[row].append(Cell(row: row, col: col, game: self))
            }
        }
    }

    override var representedObject: Any? {
        didSet {
        // Update the view, if already loaded.
        }
    }

    @IBAction func clearMines(_ sender: Any) {
        minesLaid = false
        mineTripped = false
        cellsToVisit = Int.max
        for row in cells {
            for cell in row {
                cell.isVisited = false
                cell.isMine = false
                cell.neighboringMineCount = 0
                cell.button.title = ""
            }
        }
    }

    func changeLevel(rowCount: Int, colCount: Int, minesCount: Int) {
        for row in cells {
            for cell in row {
                cell.button.removeFromSuperview()
            }
        }

        self.rowCount = rowCount
        self.colCount = colCount
        self.minesCount = minesCount
        self.cells = Array(
            repeating: [],
            count: rowCount
        )

        for row in 0..<rowCount {
            for col in 0..<colCount {
                cells[row].append(Cell(row: row, col: col, game: self))
            }
        }
        var frame = self.view.window?.frame
        frame?.size = NSSize(
            width: colCount * ViewController.cellSizePx,
            height: rowCount * ViewController.cellSizePx + 21
        )
        self.view.window?.setFrame(frame!, display: true)
    }

    @IBAction func changeLevelToBeginner(_ sender: Any) {
        changeLevel(rowCount: 9, colCount: 9, minesCount: 10)
    }

    @IBAction func changeLevelToIntermediate(_ sender: Any) {
        changeLevel(rowCount: 16, colCount: 16, minesCount: 40)
    }
    
    @IBAction func changeLevelToAdvanced(_ sender: Any) {
        changeLevel(rowCount: 16, colCount: 30, minesCount: 99)
    }
    
}
