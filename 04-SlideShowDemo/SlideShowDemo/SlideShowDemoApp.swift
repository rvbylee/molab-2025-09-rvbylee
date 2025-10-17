//
//  SlideShowDemoApp.swift
//  SlideShowDemo
//
//  Created by jht2 on 3/10/22.
//

import SwiftUI

@main
struct SlideShowDemoApp: App {
    @State var audioDJ = AudioDJ()
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(audioDJ)
        }
    }
}
