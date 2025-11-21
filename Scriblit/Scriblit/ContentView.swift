//
//  ContentView.swift
//  Scriblit
//
//  Created by Ruby Lee on 11/13/25.
//

import SwiftUI
import Combine
import PencilKit

struct ScribEntry: Identifiable, Codable {
    let id: UUID
    let date: Date
    let word: String
    let artist: String
    let caption: String
    let imageFilename: String
}

class ScribStore: ObservableObject {
    @Published var entries: [ScribEntry] = [] {
        didSet { save() }
    }
    
    private let saveURL: URL
    
    // prompts
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
        let calendar = Calendar.current
        let today = Date()
        let dayOfYear = calendar.ordinality(of: .day, in: .year, for: today) ?? 0
        let index = dayOfYear % words.count
        return words[index]
    }
    
    init() {
        let docs = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        saveURL = docs.appendingPathComponent("scriblit.json")
        load()
    }
    
    // add new entry from a UIImage (exported drawing)
    func addEntry(artist: String, caption: String, image: UIImage) {
        guard let data = image.pngData() else { return }
        
        let filename = UUID().uuidString + ".png"
        let docs = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        let imgURL = docs.appendingPathComponent(filename)
        
        do {
            try data.write(to: imgURL)
            let entry = ScribEntry(
                id: UUID(),
                date: Date(),
                word: wordOfTheDay,
                artist: artist,
                caption: caption,
                imageFilename: filename
            )
            entries.insert(entry, at: 0) // newest first
        } catch {
            print("Failed to save image:", error)
        }
    }
    
    func image(for entry: ScribEntry) -> UIImage? {
        let docs = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        let imgURL = docs.appendingPathComponent(entry.imageFilename)
        return UIImage(contentsOfFile: imgURL.path)
    }
    
    private func load() {
        if let data = try? Data(contentsOf: saveURL) {
            let decoder = JSONDecoder()
            if let decoded = try? decoder.decode([ScribEntry].self, from: data) {
                entries = decoded
            }
        }
    }
    
    private func save() {
        let encoder = JSONEncoder()
        encoder.outputFormatting = .prettyPrinted
        if let data = try? encoder.encode(entries) {
            try? data.write(to: saveURL)
        }
    }
}

// pencilkit wrapped

struct DrawingCanvasView: UIViewRepresentable {
    @Binding var drawing: PKDrawing
    
    func makeUIView(context: Context) -> PKCanvasView {
        let canvas = PKCanvasView()
        canvas.drawingPolicy = .anyInput   // finger + Apple Pencil
        canvas.backgroundColor = .systemBackground
        canvas.drawing = drawing
        return canvas
    }
    
    func updateUIView(_ canvas: PKCanvasView, context: Context) {
        canvas.drawing = drawing
    }
}

// tabs/ navigation

struct ContentView: View {
    @StateObject private var store = ScribStore()
    
    var body: some View {
        TabView {
            TodayView()
                .tabItem {
                    Label("Today", systemImage: "house")
                }
                .environmentObject(store)
            
            SubmitView()
                .tabItem {
                    Label("Submit", systemImage: "square.and.pencil")
                }
                .environmentObject(store)
            
            ArchiveView()
                .tabItem {
                    Label("Archive", systemImage: "archivebox")
                }
                .environmentObject(store)
        }
    }
}

// TODAY'S VIEW

struct TodayView: View {
    @EnvironmentObject var store: ScribStore
    
    var todaysEntries: [ScribEntry] {
        store.entries.filter { $0.word == store.wordOfTheDay }
    }
    
    var body: some View {
        NavigationStack {
            VStack(alignment: .leading, spacing: 16) {
                Text("scriblit")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                
                Text("scribble this:")
                    .font(.headline)
                
                Text(store.wordOfTheDay)
                    .font(.title3)
                    .fontWeight(.semibold)
                    .padding()
                    .background(.thinMaterial)
                    .cornerRadius(16)
                
                if todaysEntries.isEmpty {
                    Text("no scribbles yet. everyone’s pretending not to see the prompt.")
                        .foregroundColor(.secondary)
                        .padding(.top, 16)
                } else {
                    ScrollView {
                        LazyVStack(spacing: 16) {
                            ForEach(todaysEntries) { entry in
                                EntryCard(entry: entry)
                            }
                        }
                    }
                }
                
                Spacer()
            }
            .padding()
            .navigationTitle("Today")
            .navigationBarTitleDisplayMode(.inline)
        }
    }
}

// SUBMIT VIEW WITH PENCIL KIT

struct SubmitView: View {
    @EnvironmentObject var store: ScribStore
    
    @State private var artist: String = ""
    @State private var caption: String = ""
    @State private var drawing = PKDrawing()
    
    var canPost: Bool {
        !artist.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty &&
        !drawing.bounds.isEmpty
    }
    
    var body: some View {
        NavigationStack {
            VStack(alignment: .leading, spacing: 12) {
                Text("boop your scribble here")
                    .font(.title2)
                    .fontWeight(.bold)
                
                Group {
                    Text("display name:")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    TextField("something cool", text: $artist)
                        .textFieldStyle(.roundedBorder)
                    
                    Text("caption:")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    TextField("whatever", text: $caption)
                        .textFieldStyle(.roundedBorder)
                }
                
                Text("draw your scribble:")
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .padding(.top, 8)
                
                ZStack {
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(Color.secondary.opacity(0.3), lineWidth: 1)
                    DrawingCanvasView(drawing: $drawing)
                        .clipShape(RoundedRectangle(cornerRadius: 16))
                }
                .frame(height: 300)
                
                HStack {
                    Button("Clear") {
                        drawing = PKDrawing()
                    }
                    .padding(8)
                    
                    Spacer()
                    
                    Button("Upload") {
                        post()
                    }
                    .disabled(!canPost)
                    .padding()
                    .background(canPost ? Color.primary : Color.gray.opacity(0.4))
                    .foregroundColor(.white)
                    .cornerRadius(12)
                }
                .padding(.top, 8)
                
                Spacer()
            }
            .padding()
            .navigationTitle("Submit")
            .navigationBarTitleDisplayMode(.inline)
        }
    }
    
    func post() {
        // turn PKDrawing into UIImage
        let image = drawing.image(from: drawing.bounds, scale: 1.0)
        store.addEntry(artist: artist, caption: caption, image: image)
        
        // reset form
        artist = ""
        caption = ""
        drawing = PKDrawing()
    }
}

//ARCHIVE VIEW

struct ArchiveView: View {
    @EnvironmentObject var store: ScribStore
    
    // group entries by word
    var grouped: [(String, [ScribEntry])] {
        let dict = Dictionary(grouping: store.entries, by: { $0.word })
        return dict
            .map { (word, entries) in
                (word, entries.sorted { $0.date > $1.date })
            }
            .sorted { lhs, rhs in
                (lhs.1.first?.date ?? .distantPast) > (rhs.1.first?.date ?? .distantPast)
            }
    }
    
    var body: some View {
        NavigationStack {
            Group {      // single root view inside NavigationStack
                if grouped.isEmpty {
                    VStack(spacing: 12) {
                        Text("archive dump")
                            .font(.largeTitle)
                            .fontWeight(.bold)
                        Text("no archives yet, you're early.")
                            .foregroundColor(.secondary)
                    }
                    .padding()
                } else {
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
        }
    }
}

// reusable card view

struct EntryCard: View {
    @EnvironmentObject var store: ScribStore
    let entry: ScribEntry
    
    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            if let image = store.image(for: entry) {
                Image(uiImage: image)
                    .resizable()
                    .scaledToFit()
                    .cornerRadius(12)
            }
            
            Text(entry.artist)
                .font(.subheadline)
                .fontWeight(.semibold)
            
            if !entry.caption.isEmpty {
                Text(entry.caption)
                    .font(.body)
            }
            
            Text(entry.date.formatted(date: .abbreviated, time: .shortened))
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .padding()
        .background(Color(.secondarySystemBackground))
        .cornerRadius(16)
    }
}

#Preview {
    ContentView()
}


