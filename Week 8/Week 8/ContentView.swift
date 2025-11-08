//
//  ContentView.swift
//  PhotoEditor
//
//  Created by Ruby on 11/07/25.
//

import SwiftUI
import PhotosUI
import CoreImage
import CoreImage.CIFilterBuiltins

struct ContentView: View {

    // photo picking
    @State private var pickerItem: PhotosPickerItem?
    @State private var inputUIImage: UIImage?
    
    // image processing
    @State private var ciContext = CIContext()
    @State private var outputUIImage: UIImage?       // for saving to Photos
    @State private var outputImage: Image?           // for showing in SwiftUI
    
    // controls
    enum FilterKind: String, CaseIterable, Identifiable {
        case none = "None"
        case sepia = "Sepia"
        case noir = "Noir"
        case vignette = "Vignette"
        var id: String { rawValue }
    }
    
    @State private var filter: FilterKind = .none
    @State private var saturation: Double = 1.0
    @State private var sepiaAmount: Double = 0.6
    @State private var vignetteAmount: Double = 0.8
    
    @State private var showSavedAlert = false
    
    var body: some View {
        NavigationStack {
            ZStack {
                // light pink background
                Color(.systemPink)
                    .opacity(0.15)
                    .ignoresSafeArea()
                
                VStack(spacing: 16) {
                    // image area
                    PhotosPicker(selection: $pickerItem, matching: .images) {
                        ZStack {
                            Rectangle().fill(.gray.opacity(0.08))
                            if let img = outputImage {
                                img
                                    .resizable()
                                    .scaledToFit()
                                    .cornerRadius(12)
                                    .shadow(radius: 3)
                                    .padding(.horizontal)
                            } else {
                                ContentUnavailableView(
                                    "Tap to choose a photo",
                                    systemImage: "photo.on.rectangle",
                                    description: Text("Then tweak saturation or add a filter.")
                                )
                            }
                        }
                        .frame(height: 320)
                        .contentShape(Rectangle())
                    }
                    .buttonStyle(.plain)
                    .onChange(of: pickerItem) { _, _ in loadPickedPhoto() }
                    
                    // controls
                    Group {
                        // filter picker
                        Picker("Filter", selection: $filter) {
                            ForEach(FilterKind.allCases) { kind in
                                Text(kind.rawValue).tag(kind)
                            }
                        }
                        .pickerStyle(.segmented)
                        .onChange(of: filter) { _, _ in applyProcessing() }
                        
                        // Saturation
                        HStack {
                            Text("Saturation")
                            Slider(value: $saturation, in: 0...2, step: 0.01) { _ in
                                applyProcessing()
                            }
                        }
                        
                        // Extra sliders for specific filters
                        if filter == .sepia {
                            HStack {
                                Text("Sepia")
                                Slider(value: $sepiaAmount, in: 0...1, step: 0.01) { _ in
                                    applyProcessing()
                                }
                            }
                        }
                        
                        if filter == .vignette {
                            HStack {
                                Text("Vignette")
                                Slider(value: $vignetteAmount, in: 0...2, step: 0.01) { _ in
                                    applyProcessing()
                                }
                            }
                        }
                    }
                    .padding(.horizontal)
                    
                    // actions
                    HStack(spacing: 12) {
                        Button {
                            resetImage()
                        } label: {
                            Label("Reset", systemImage: "arrow.uturn.left")
                                .frame(maxWidth: .infinity)
                        }
                        .buttonStyle(.bordered)
                        .disabled(inputUIImage == nil)
                        
                        Button {
                            saveToPhotos()
                        } label: {
                            Label("Save", systemImage: "square.and.arrow.down")
                                .frame(maxWidth: .infinity)
                        }
                        .buttonStyle(.borderedProminent)
                        .tint(.pink)
                        .disabled(outputUIImage == nil)
                    }
                    .padding(.horizontal)
                    .alert("Saved to Photos", isPresented: $showSavedAlert) {
                        Button("OK", role: .cancel) { }
                    }
                    
                    Spacer()
                }
            }
            // center title
            .toolbar {
                ToolbarItem(placement: .principal) {
                    Text("Photo Editor")
                                .font(.largeTitle)        
                                .fontWeight(.bold)
        
                        }
                    }
        }
    }
}

// helpers
extension ContentView {
    private func loadPickedPhoto() {
        Task {
            guard
                let data = try? await pickerItem?.loadTransferable(type: Data.self),
                let ui = UIImage(data: data)
            else { return }
            
            inputUIImage = ui
            outputUIImage = ui
            outputImage = Image(uiImage: ui)
            applyProcessing()
        }
    }
    
    // applies saturation and selected filter
    private func applyProcessing() {
        guard let base = inputUIImage, let ciInput = CIImage(image: base) else { return }
        
        // 1) Color controls (saturation)
        let colorControls = CIFilter.colorControls()
        colorControls.inputImage = ciInput
        colorControls.saturation = Float(saturation)
        
        var working = colorControls.outputImage ?? ciInput
        
        // 2) Optional filter layer
        switch filter {
        case .none:
            break
            
        case .sepia:
            let sepia = CIFilter.sepiaTone()
            sepia.inputImage = working
            sepia.intensity = Float(sepiaAmount)
            working = sepia.outputImage ?? working
            
        case .noir:
            if let noir = CIFilter(name: "CIPhotoEffectNoir") {
                noir.setValue(working, forKey: kCIInputImageKey)
                if let out = noir.outputImage { working = out }
            }
            
        case .vignette:
            let vignette = CIFilter.vignette()
            vignette.inputImage = working
            vignette.intensity = Float(vignetteAmount)
            vignette.radius = 2.0
            working = vignette.outputImage ?? working
        }
        
        if let cg = ciContext.createCGImage(working, from: working.extent) {
            let outUI = UIImage(cgImage: cg)
            outputUIImage = outUI
            outputImage = Image(uiImage: outUI)
        }
    }
    
    // restores sliders and image to original
    private func resetImage() {
        filter = .none
        saturation = 1.0
        sepiaAmount = 0.6
        vignetteAmount = 0.8
        if let original = inputUIImage {
            outputUIImage = original
            outputImage = Image(uiImage: original)
            applyProcessing()
        }
    }
    
    // saves to user's photos
    private func saveToPhotos() {
        guard let img = outputUIImage else { return }
        UIImageWriteToSavedPhotosAlbum(img, nil, nil, nil)
        showSavedAlert = true
    }
}

#Preview {
    ContentView()
}

