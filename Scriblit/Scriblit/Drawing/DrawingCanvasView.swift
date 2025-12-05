//
//  DrawingCanvasView.swift
//  Scriblit
//
//  Created by Ruby Lee on 11/21/25.
//

import SwiftUI
import PencilKit

struct DrawingCanvasView: UIViewRepresentable {
    @Binding var drawing: PKDrawing
    
    // coordinator lets the canvas update the @Binding
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    class Coordinator: NSObject, PKCanvasViewDelegate {
        var parent: DrawingCanvasView
        
        init(_ parent: DrawingCanvasView) {
            self.parent = parent
        }
        
        func canvasViewDrawingDidChange(_ canvasView: PKCanvasView) {
            // push the updated drawing back into SwiftUI state
            parent.drawing = canvasView.drawing
        }
    }
    
    func makeUIView(context: Context) -> PKCanvasView {
        let canvas = PKCanvasView()
        canvas.backgroundColor = .systemBackground
        canvas.drawingPolicy = .anyInput
        canvas.drawing = drawing
        canvas.delegate = context.coordinator   // listen for changes
        return canvas
    }
    
    func updateUIView(_ canvas: PKCanvasView, context: Context) {
        canvas.drawing = drawing
    }
}

