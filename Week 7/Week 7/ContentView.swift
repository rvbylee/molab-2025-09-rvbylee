//
//  ContentView.swift
//  Week 7
//
//  Created by Ruby Lee on 10/24/25.
//

import SwiftUI
import PhotosUI
import CoreImage
import CoreImage.CIFilterBuiltins
import UniformTypeIdentifiers

struct ContentView: View {
    @State private var selectedItem: PhotosPickerItem?
    @State private var inputImage: UIImage?
    @State private var dominantColors: [Color] = []
    @State private var showingSavedAlert = false

    var body: some View {
        NavigationStack {
            VStack(spacing: 24) {
                Spacer()

                // Pick / show image
                PhotosPicker(selection: $selectedItem) {
                    if let inputImage {
                        Image(uiImage: inputImage)
                            .resizable()
                            .scaledToFit()
                            .cornerRadius(12)
                            .shadow(radius: 4)
                            .padding(.horizontal)
                    } else {
                        ContentUnavailableView(
                            "No image yet",
                            systemImage: "photo.badge.plus",
                            description: Text("Tap to pick a photo")
                        )
                    }
                }
                .buttonStyle(.plain)
                .onChange(of: selectedItem, loadPhoto)

                Spacer()

                // Palette
                if !dominantColors.isEmpty {
                    VStack(spacing: 8) {
                        Text("Dominant Colors").font(.headline)
                        HStack {
                            ForEach(dominantColors, id: \.self) { color in
                                color
                                    .frame(width: 50, height: 50)
                                    .clipShape(RoundedRectangle(cornerRadius: 10))
                                    .shadow(radius: 2)
                            }
                        }
                    }
                }

                // Save palette strip
                if !dominantColors.isEmpty {
                    Button {
                        savePaletteStrip()
                    } label: {
                        Label("Save Palette", systemImage: "square.and.arrow.down")
                            .font(.headline)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 10)
                            .background(.mint.opacity(0.3))
                            .clipShape(RoundedRectangle(cornerRadius: 12))
                    }
                    .padding(.horizontal)
                    .alert("Saved to Photos", isPresented: $showingSavedAlert) {
                        Button("OK", role: .cancel) { }
                    }
                }

                Spacer()
            }
            .padding(.bottom, 24)
            .navigationTitle("ColorMood")
        }
    }

   
    func loadPhoto() {
        Task {
            guard let data = try await selectedItem?.loadTransferable(type: Data.self),
                  let ui = UIImage(data: data)
            else { return }
            inputImage = ui
            extractColors(from: ui)
        }
    }

    // Extract 5 dominant colors
    func extractColors(from image: UIImage) {
        guard let cg = image.cgImage else { return }

        let w = 64, h = 64
        guard let ctx = CGContext(
            data: nil,
            width: w, height: h,
            bitsPerComponent: 8,
            bytesPerRow: w * 4,
            space: CGColorSpaceCreateDeviceRGB(),
            bitmapInfo: CGImageAlphaInfo.premultipliedLast.rawValue
        ) else { return }

        ctx.interpolationQuality = .low
        ctx.draw(cg, in: CGRect(x: 0, y: 0, width: w, height: h))
        guard let buf = ctx.data else { return }

        let px = buf.bindMemory(to: UInt8.self, capacity: w * h * 4)
        var buckets: [UInt32: Int] = [:]

        for y in 0..<h {
            for x in 0..<w {
                let i = 4 * (y * w + x)
                let r = px[i], g = px[i+1], b = px[i+2]

                // reduce precision cluster similar colors
                let key = (UInt32(r >> 4) << 8) | (UInt32(g >> 4) << 4) | UInt32(b >> 4)
                buckets[key, default: 0] += 1
            }
        }

        let top = buckets.sorted { $0.value > $1.value }.prefix(5)
        dominantColors = top.map { (key, _) in
            let r4 = Double((key >> 8) & 0xF) / 15.0
            let g4 = Double((key >> 4) & 0xF) / 15.0
            let b4 = Double(key & 0xF) / 15.0
            return Color(red: r4, green: g4, blue: b4)
        }
    }

    // Save palette as a horizontal strip image
    func savePaletteStrip() {
        let renderer = ImageRenderer(content:
            HStack(spacing: 0) {
                ForEach(dominantColors, id: \.self) { c in c }
            }
            .frame(width: 1000, height: 200) //export
        )

        if let img = renderer.uiImage {
            UIImageWriteToSavedPhotosAlbum(img, nil, nil, nil)
            showingSavedAlert = true
        }
    }
}

#Preview {
    ContentView()
}
  
