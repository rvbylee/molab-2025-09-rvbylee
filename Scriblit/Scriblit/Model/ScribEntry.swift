//
//  ScribEntry.swift
//  Scriblit
//
//  Created by Ruby Lee on 11/21/25.
//

import Foundation

struct ScribEntry: Identifiable, Codable {
    let id: UUID
    let date: Date
    let word: String
    let artist: String
    let caption: String
    let imageFilename: String
    let imageData: Data?
}

extension ScribEntry {
    init(
        word: String,
        artist: String,
        caption: String,
        imageData: Data?,
        imageFilename: String = ""
    ) {
        self.id = UUID()
        self.date = Date()
        self.word = word
        self.artist = artist
        self.caption = caption
        self.imageFilename = imageFilename
        self.imageData = imageData
    }
}

