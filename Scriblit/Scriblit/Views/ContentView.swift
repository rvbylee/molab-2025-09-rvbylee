//
//  ContentView.swift
//  Scriblit
//
import SwiftUI

struct ContentView: View {
    @EnvironmentObject var store: ScribStore    // 👈 now coming from ScriblitApp

    var body: some View {
        ZStack {
            // Background grid image
            Image("gridbackground")
                .resizable(resizingMode: .tile)  // repeat like paper
                .ignoresSafeArea()
                .opacity(0.15)                   // tweak how strong it looks

            TabView {
                TodayView()
                    .environmentObject(store)
                    .tabItem { Label("Today", systemImage: "house") }

                SubmitView()
                    .environmentObject(store)
                    .tabItem { Label("Submit", systemImage: "square.and.pencil") }

                ArchiveView()
                    .environmentObject(store)
                    .tabItem { Label("Archive", systemImage: "archivebox") }
            }
        }
    }
}

#Preview {
    ContentView()
        .environmentObject(ScribStore())    // 👈 needed for preview to compile
}


