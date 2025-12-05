//
//  TodayView.swift
//  Scriblit
//
//  Created by Ruby Lee on 11/21/25.
//

import SwiftUI

struct TodayView: View {
    @EnvironmentObject var store: ScribStore
    @State private var pressed = false
    @State private var navigateToSubmit = false
    
    var todaysEntries: [ScribEntry] {
        store.entries.filter { $0.word == store.wordOfTheDay }
    }
    
    var body: some View {
        NavigationStack {
            ZStack {
                Image("gridbackground")
                    .resizable(resizingMode: .tile)
                    .scaleEffect(1.0)
                    .ignoresSafeArea()
                    .opacity(0.35)

                VStack(alignment: .leading, spacing: 16) {
                    
                    // mark gif logo
                    GIFView(gifName: "scriblit")
                        .frame(width: 200, height: 70)
                        .padding(.top, 4)
      
                    // Mark Submit Button
                    Button(action: {
                        navigateToSubmit = true
                    }) {
                        Image(pressed ? "submithover" : "submit")
                            .renderingMode(.original)
                            .resizable()
                            .interpolation(.none)
                            .scaledToFit()
                            .frame(width: 300, height: 90)
                            .padding(.leading, -100)   // tweak these to position it
                            .offset(y: -4)
                    }
                    .onLongPressGesture(minimumDuration: 0.01) {
                        pressed = true
                    } onPressingChanged: { isPressing in
                        pressed = isPressing
                    }
                    
                
                    NavigationLink(
                        destination: SubmitView(),
                        isActive: $navigateToSubmit
                    ) {
                        EmptyView()
                    }
                    .hidden()
                    
                    // word of the day
                    Text(store.wordOfTheDay)
                        .font(.title3)
                        .fontWeight(.semibold)
                        .padding()
                        .background(.thinMaterial)
                        .cornerRadius(16)
                        .offset(x: 20)

                    if todaysEntries.isEmpty {
                        VStack {
                            Spacer().frame(height: 120)
                            Text("no scribbles yet. everyone’s pretending not to see the prompt.")
                                .foregroundColor(.secondary)
                                .italic()
                            Spacer()
                        }
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
            }
            .navigationTitle("Today")
            .navigationBarTitleDisplayMode(.inline)
        }
    }

}

#Preview {
    ContentView()
}


