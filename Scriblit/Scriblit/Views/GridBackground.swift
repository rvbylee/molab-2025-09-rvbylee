//
//  GridBackground.swift
//  Scriblit
//
//  Created by Ruby Lee on 11/26/25.
//

import SwiftUI

struct GridPaperBackground: ViewModifier {
    func body(content: Content) -> some View {
        ZStack {
            Image("gridbackground")
                .resizable(resizingMode: .tile)
                .scaleEffect(1.0)     // tweak size here
                .ignoresSafeArea()
                .opacity(0.35)

            content
        }
    }
}

extension View {
    func gridPaperBackground() -> some View {
        self.modifier(GridPaperBackground())
    }
}
