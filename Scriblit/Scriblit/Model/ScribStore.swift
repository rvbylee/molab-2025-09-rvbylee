//
//  ScribStore.swift
//  Scriblit
//
//  Created by Ruby Lee on 11/21/25.
//

import Foundation
import UIKit
import Combine

class ScribStore: ObservableObject {
    @Published var entries: [ScribEntry] = [] {
        didSet { save() }
    }
    
    private let saveURL: URL
    
    private let words: [String] = [
        "the thing standing in my room during sleep paralysis",
        "friend: whats the big idea? the big idea",
        "grandma at a rave",
        "monster under the bed",
        "my art professor looking at my 'piece'",
        "friend: whats the problem? the problem",
        "what the last potato chip in the bag sees",
        "dad at coachella",
        "librarian at a mosh pit",
        "how my parents got to school",
        "what heaven actually looks like",
        "cat judging you across the room",
        "fish forgetting how to swim",
        "fish in a suit",
        "sandwich",
        "pizza in love"
    ]
    
    var wordOfTheDay: String {
        let today = Date()
        let dayOfYear = Calendar.current.ordinality(of: .day, in: .year, for: today) ?? 0
        return words[dayOfYear % words.count]
    }
    
    init() {
        let docs = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        self.saveURL = docs.appendingPathComponent("scriblit.json")
        load()
    }
    
    func addEntry(artist: String, caption: String, image: UIImage) {
        guard let data = image.pngData() else { return }
        
        let filename = UUID().uuidString + ".png"
        let docs = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        let imgURL = docs.appendingPathComponent(filename)
        
        do {
            // save PNG to disk
            try data.write(to: imgURL)
            
            // use your convenience init (no id/date here)
            let entry = ScribEntry(
                word: wordOfTheDay,
                artist: artist,
                caption: caption,
                imageData: data,
                imageFilename: filename
            )
            
            // newest first
            entries.insert(entry, at: 0)
        } catch {
            print("Error saving image:", error)
        }
    }
    
    func image(for entry: ScribEntry) -> UIImage? {
        // prefer loading from disk using filename
        let docs = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        let imgURL = docs.appendingPathComponent(entry.imageFilename)
        return UIImage(contentsOfFile: imgURL.path)
    }
    
    private func load() {
        guard let data = try? Data(contentsOf: saveURL) else { return }
        entries = (try? JSONDecoder().decode([ScribEntry].self, from: data)) ?? []
    }
    
    private func save() {
        guard let data = try? JSONEncoder().encode(entries) else { return }
        try? data.write(to: saveURL)
    }
}


