//
//  TodayViewController.swift
//  MinesweeperWidget
//
//  Created by Jack Leow on 9/3/21.
//  Copyright © 2021 Jack Leow. All rights reserved.
//

import Cocoa
import NotificationCenter

class TodayViewController: NSViewController, NCWidgetProviding {

    override var nibName: NSNib.Name? {
        return NSNib.Name("TodayViewController")
    }

    func widgetPerformUpdate(completionHandler: (@escaping (NCUpdateResult) -> Void)) {
        // Update your data and prepare for a snapshot. Call completion handler when you are done
        // with NoData if nothing has changed or NewData if there is new data since the last
        // time we called you
        completionHandler(.noData)
    }

    static let cellSizePx: Double = 304.0 / 9

    class Cell {
        let row: Int
        let col: Int
        let game: TodayViewController
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

        init(row: Int, col: Int, game: TodayViewController) {
            self.row = row
            self.col = col
            self.game = game
            button = NSButton(
                frame: CGRect(
                    x: Double(col) * TodayViewController.cellSizePx,
                    y: Double(row) * TodayViewController.cellSizePx + 40,
                    width: TodayViewController.cellSizePx,
                    height: TodayViewController.cellSizePx + 2
                )
            )
            button.font = NSFont.boldSystemFont(ofSize: 0)
            button.title = ""
            button.alphaValue = 0.8
            button.bezelStyle = NSButton.BezelStyle.smallSquare
            button.focusRingType = .none
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

    @objc func clearMines(_ sender: Any) {
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

    override func viewDidLoad() {
        super.viewDidLoad()

        for row in 0..<rowCount {
            for col in 0..<colCount {
                cells[row].append(Cell(row: row, col: col, game: self))
            }
        }
        
        let newGameButton: NSButton = NSButton(
            frame: CGRect(x: 0, y: 0, width: 306, height: 32)
        )
        newGameButton.title = "New Game"
        newGameButton.alphaValue = 0.8
        newGameButton.bezelStyle = NSButton.BezelStyle.smallSquare
        newGameButton.target = self
        newGameButton.action = #selector(clearMines)
        self.view.addSubview(newGameButton)
    }

}
