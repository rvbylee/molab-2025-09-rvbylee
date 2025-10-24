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

    func playSound(_ name: String) {
        if let soundURL = Bundle.main.url(forResource: name, withExtension: "mp3") {
            do {
                audioPlayer = try AVAudioPlayer(contentsOf: soundURL)
                audioPlayer?.play()
            } catch {
                print("Error: couldn't play \(name) sound.")
            }
        } else {
            print("Sound file not found.")
        }
    }

    var body: some View {
        VStack(spacing: 40) {
            Text("🐾 Animal Sounds 🐾")
                .font(.largeTitle)
                .fontWeight(.bold)

            //Dog
            Button(action: { playSound("dog") }) {
                VStack {
                    Image(systemName: "pawprint.fill")
                        .resizable()
                        .frame(width: 80, height: 80)
                    Text("Dog")
                        .font(.title2)
                }
            }

            //Cat
            Button(action: { playSound("cat") }) {
                VStack {
                    Image(systemName: "cat.fill")
                        .resizable()
                        .frame(width: 80, height: 80)
                    Text("Cat")
                        .font(.title2)
                }
            }

            //Turtle
            Button(action: { playSound("turtle") }) {
                VStack {
                    Image(systemName: "tortoise.fill")
                        .resizable()
                        .frame(width: 80, height: 80)
                    Text("Turtle")
                        .font(.title2)
                }
            }
        }
        .padding()
    }
}

#Preview {
    ContentView()
}

