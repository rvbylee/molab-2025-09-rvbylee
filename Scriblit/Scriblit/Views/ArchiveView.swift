//
//  ArchiveView.swift
//  Scriblit
//
//  Created by Ruby Lee on 11/21/25.
//

import SwiftUI

struct ArchiveView: View {
    @EnvironmentObject var store: ScribStore
    
    // group entries by word
    var grouped: [(String, [ScribEntry])] {
        let dict = Dictionary(grouping: store.entries, by: { $0.word })
        return dict
            .map { (word, entries) in
                (word, entries.sorted { $0.date > $1.date })
            }
            .sorted { $0.0 < $1.0 }
    }
    
    var body: some View {
        NavigationStack {
            
            Group {     // ensures both states behave the same
                if grouped.isEmpty {
                    // EMPTY STATE — centered
                    VStack(spacing: 8) {
                        Spacer()
                        
                        Text("archive dump")
                            .font(.largeTitle)
                            .fontWeight(.bold)
                        
                        Text("no archives yet, you're early.")
                            .foregroundColor(.secondary)
                            .italic()
                        
                        Spacer()
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    
                } else {
                    // NORMAL ARCHIVE LIST
                    ScrollView {
                        VStack(alignment: .leading, spacing: 24) {
                            Text("archive dump")
                                .font(.largeTitle)
                                .fontWeight(.bold)
                            
                            ForEach(grouped, id: \.0) { word, entries in
                                VStack(alignment: .leading, spacing: 8) {
                                    Text(word)
                                        .font(.headline)
                                    
                                    ForEach(entries) { entry in
                                        EntryCard(entry: entry)
                                    }
                                }
                            }
                        }
                        .padding()
                    }
                }
            }
            .navigationTitle("Archive")
            .navigationBarTitleDisplayMode(.inline)
            .gridPaperBackground()  
        }
    }
}

#Preview {
    ArchiveView()
        .environmentObject(ScribStore())
}
