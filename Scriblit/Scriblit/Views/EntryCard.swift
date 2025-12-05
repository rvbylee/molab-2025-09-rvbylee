//
//  EntryCard.swift
//  Scriblit
//
//  Created by Ruby Lee on 11/21/25.
//
//

import SwiftUI

struct EntryCard: View {
    @EnvironmentObject var store: ScribStore
    let entry: ScribEntry

    // formatted date string
    private var dateString: String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        return formatter.string(from: entry.date)
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {

            // 1. THE DRAWING
            if let uiImage = store.image(for: entry) {
                Image(uiImage: uiImage)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(maxHeight: 260)         // tweak size if you want
                    .clipShape(RoundedRectangle(cornerRadius: 16))
            }

            // 2. ARTIST
            Text(entry.artist)
                .font(.headline)

            // 3. CAPTION (optional)
            if !entry.caption.isEmpty {
                Text(entry.caption)
                    .font(.subheadline)
            }

            // 4. DATE
            Text(dateString)
                .font(.caption2)
                .foregroundColor(.secondary)
        }
        .padding()
        .background(Color(.systemBackground).opacity(0.9))
        .cornerRadius(20)
        .shadow(color: Color.black.opacity(0.05), radius: 4, x: 0, y: 2)
    }
}

#Preview {
    let sample = ScribEntry(
        word: "what heaven actually looks like",
        artist: "Ruby",
        caption: "Yes\nNo",
        imageData: nil,            // MUST COME BEFORE imageFilename
        imageFilename: "example.png"
    )

    EntryCard(entry: sample)
        .environmentObject(ScribStore())
        .padding()
        .previewLayout(.sizeThatFits)
}




