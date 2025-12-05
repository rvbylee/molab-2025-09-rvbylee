//
//  ScriblitApp.swift
//  Scriblit
//
//  Created by Ruby Lee on 11/13/25.
//

import SwiftUI
import FirebaseCore

@main
struct ScriblitApp: App {
    @StateObject private var auth = AuthManager()
    @StateObject private var store = ScribStore()

    init() {
        FirebaseApp.configure()
    }

    var body: some Scene {
        WindowGroup {
            Group {
                if auth.user != nil {
                    // logged in → show main Scriblit app
                    ContentView()
                        .environmentObject(store)
                } else {
                    // not logged in → show login screen
                    LoginView()
                }
            }
            .environmentObject(auth)
        }
    }
}

