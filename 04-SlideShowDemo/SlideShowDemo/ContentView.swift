//
//  ContentView.swift
//  SlideShowDemo
//
//  Created by jht2 on 3/10/22.
//

import SwiftUI

// system symbol names for each slide
// could passed as EnvironmentObject
//
let slides = ["fish","ant","hare","ladybug","tortoise"]

struct ContentView: View {
    var body: some View {
        NavigationView {
            VStack {
                Text("Slide Show Demo")
                    .padding()
                    .font(.largeTitle)
                NavigationLink (destination: SlideShowView()) {
                    Text("Slide Show")
                        .padding()
                }
                NavigationLink (destination: SlidesAudioView()) {
                    Text("Slides Audio")
                }
                Spacer()
            }
        }
    }
}

// AudioDJ must be established here to avoid crash in preview
#Preview {
    ContentView()
        .environment(AudioDJ())
}
