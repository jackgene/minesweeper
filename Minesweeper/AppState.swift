//
//  AppState.swift
//  Minesweeper
//
//  Created by Jack Leow on 2/27/24.
//

import Combine

class CellState: ObservableObject {
    @Published var label: String? = nil
}
class AppState: ObservableObject {
    @Published var size: Size = Size(width: 0, height: 0)
    @Published var cells: [[CellState]] = []
    @Published var resetable: Bool = false
    let input: some Subject<Input, Never> = CurrentValueSubject(
        .changeLevel(level: .beginner)
    )
    
    private var cancellables: Set<AnyCancellable> = []
    
    init() {
        input
            .compactMap {
                switch $0 {
                case .changeLevel(level: let level):
                    level.size
                case .startOver, .visit(_):
                    nil
                }
            }
            .assign(to: &$size)
        
        $size
            .map { (size: Size) in
                (0..<size.height).map { _ in
                    (0..<size.width).map { _ in
                        CellState()
                    }
                }
            }
            .assign(to: &$cells)
        
        let mineFields: some Publisher<MineField, Never> = input
            .scan(.uninitialized(level: .beginner)) { (lastMineField: MineField, input: Input) in
                let nextMineField: MineField = input.update(mineField: lastMineField)
                return nextMineField
            }
            .share()
        
        mineFields
            .sink {
                for (labels, cells): ([String?], [CellState]) in zip($0.cellLabels, self.cells) {
                    for (label, cell): (String?, CellState) in zip(labels, cells) {
                        if cell.label != label {
                            cell.label = label
                        }
                    }
                }
            }
            .store(in: &cancellables)
        
        mineFields
            .map {
                switch $0 {
                case .uninitialized(_): false
                case .sweeping(_, _), .tripped(_, _), .swept(_): true
                }
            }
            .removeDuplicates()
            .assign(to: &$resetable)
    }
}

