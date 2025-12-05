//
//  SubmitView.swift
//  Scriblit
//
//  Created by Ruby Lee on 11/21/25.
//

import SwiftUI
import PencilKit

struct SubmitView: View {
    @EnvironmentObject var store: ScribStore
    
    @State private var artist = ""
    @State private var caption = ""
    @State private var drawing = PKDrawing()
    
    // Only require a display name for now
    var canPost: Bool {
        !artist.trimmingCharacters(in: .whitespaces).isEmpty
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
                    TextField("something cool", text: $artist)
                        .textFieldStyle(.roundedBorder)
                    
                    Text("caption:")
                        .font(.caption)
                    TextField("whatever", text: $caption)
                        .textFieldStyle(.roundedBorder)
                }
                
                Text("draw your scribble:")
                    .font(.caption)
                    .padding(.top, 6)
                
                ZStack {
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(Color.secondary.opacity(0.3))
                    DrawingCanvasView(drawing: $drawing)
                        .clipShape(RoundedRectangle(cornerRadius: 16))
                }
                .frame(height: 300)
                
                HStack {
                    Button("Clear") {
                        drawing = PKDrawing()
                    }
                    .padding(.leading, 4)
                    
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
                
                Spacer()
            }
            .padding()
            .navigationTitle("Submit")
            .navigationBarTitleDisplayMode(.inline)
            .gridPaperBackground()
        }
    }
    
    func post() {
        // Use where the actual pencil strokes exist
        let bounds = drawing.bounds
        
        // If user didn’t draw anything, bounds will be empty
        guard !bounds.isEmpty else {
            print("⚠️ No drawing to save")
            return
        }
        
        // Render ONLY the actual drawn content
        let image = drawing.image(from: bounds, scale: UIScreen.main.scale)
        
        // Store the entry
        store.addEntry(artist: artist, caption: caption, image: image)
        
        // Reset for next time
        artist = ""
        caption = ""
        drawing = PKDrawing()
    }

}

#Preview {
    ContentView()
        .environmentObject(ScribStore())
}

