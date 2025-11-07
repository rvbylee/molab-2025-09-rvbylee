//
//  ContentView.swift
//  AnimalSoundApp
//
//  Created by Ruby Lee on 10/24/25.
//

import SwiftUI
import AVFoundation

struct ContentView: View {
    @State private var audioPlayer: AVAudioPlayer?
    
    // saves data even after app closes
    @AppStorage("lastAnimal") var lastAnimal = "None"
    @AppStorage("isMuted") var isMuted = false

    func playSound(_ name: String) {
        lastAnimal = name
        
        if isMuted { return } // if muted do nothing
        
        if let soundURL = Bundle.main.url(forResource: name, withExtension: "mp3") {
            do {
                audioPlayer = try AVAudioPlayer(contentsOf: soundURL)
                audioPlayer?.play()
            } catch {
                print("Error playing sound.")
            }
        } else {
            print("Sound not found.")
        }
    }

    var body: some View {
        NavigationStack {
            VStack(spacing: 30) {
                Text("Animal Sounds")
                    .font(.largeTitle)
                    .bold()
                
                Text("Last played: \(lastAnimal.capitalized)")
                    .font(.subheadline)
                    .foregroundColor(.gray)
                
                Button("Dog 🐶") {
                    playSound("dog")
                }
                .font(.title2)
                
                Button("Cat 🐱") {
                    playSound("cat")
                }
                .font(.title2)
                
                Button("Turtle 🐢") {
                    playSound("turtle")
                }
                .font(.title2)
                
                Toggle("Mute Sounds", isOn: $isMuted)
                    .padding(.top)
            }
            .padding()
        }
    }
}

#Preview {
    ContentView()
}

