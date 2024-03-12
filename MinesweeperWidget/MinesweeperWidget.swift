//
//  MinesweeperWidget.swift
//  MinesweeperWidget
//
//  Created by Jack Leow on 3/5/24.
//

import SwiftUI
import WidgetKit

struct Provider: TimelineProvider {
    private var mineField: MineField {
        if
            let mineFieldJSON: Data = store.data(forKey: mineFieldJSONKey),
            let mineField: MineField = try? .from(json: mineFieldJSON)
        {
            mineField
        } else {
            .uninitialized(level: .beginner)
        }
    }
    
    func placeholder(in context: Context) -> MineFieldEntry {
        MineFieldEntry(date: Date(), mineField: .uninitialized(level: .beginner))
    }
    
    func getSnapshot(in context: Context, completion: @escaping (MineFieldEntry) -> ()) {
        let entry = MineFieldEntry(date: Date(), mineField: mineField)
        completion(entry)
    }
    
    func getTimeline(in context: Context, completion: @escaping (Timeline<Entry>) -> ()) {
        completion(
            Timeline(
                entries: [MineFieldEntry(date: Date(), mineField: mineField)],
                policy: .never
            )
        )
    }
}

struct MineFieldEntry: TimelineEntry {
    let date: Date
    let mineField: MineField
}

struct MinesweeperWidgetEntryView : View {
    let entry: Provider.Entry
    
    var body: some View {
        let cellLabels: [[String?]] = entry.mineField.cellLabels
        
        VStack(spacing: 20) {
            ForEach(
                0..<cellLabels.count, id: \.self
            ) { (top: Int) in
                
                HStack {
                    ForEach(
                        0..<cellLabels[top].count, id: \.self
                    ) { (left: Int) in
                        let label: String? = cellLabels[top][left]
                        
                        Button(intent: VisitCellIntent(top: top, left: left)) {
                            Text(label ?? "")
                                .font(.title3)
                                .frame(width: 15, height: 24)
                        }
                        .disabled(label != nil)
                        .focusable(false)
                        .padding(-6)
                        .cornerRadius(2)
                        .foregroundStyle(.gray)
                    }
                }
                .padding(-8)
            }
            
            Button(intent: StartOverIntent()) {
                Text("New Game")
                    .font(.title2)
                    .frame(height: 8)
            }
//            .disabled(!appState.resetable)
        }
        .padding()
    }
}

struct MinesweeperWidget: Widget {
    let kind: String = "MinesweeperWidget"
    
    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: Provider()) { entry in
            MinesweeperWidgetEntryView(entry: entry)
                .containerBackground(.white, for: .widget)
        }
        .configurationDisplayName("Minesweeper")
        .description("Minesweeper")
        .supportedFamilies([.systemLarge])
    }
}
