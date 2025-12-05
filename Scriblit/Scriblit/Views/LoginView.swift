//
//  LoginView.swift
//  Scriblit
//
//  Created by Ruby Lee on 12/5/25.
//
import SwiftUI

struct LoginView: View {
    @EnvironmentObject var auth: AuthManager

    @State private var email = ""
    @State private var password = ""
    @State private var isSignUp = false
    @State private var errorMessage: String?
    @State private var isLoading = false

    var canSubmit: Bool {
        !email.isEmpty && password.count >= 6 && !isLoading
    }

    var body: some View {
        VStack(spacing: 18) {
            Text("Scriblit")
                .font(.largeTitle)
                .bold()

            Text(isSignUp ? "Create an account to save your scribbles" :
                            "Sign in to your scribbles")
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)

            TextField("Email", text: $email)
                .textInputAutocapitalization(.never)
                .keyboardType(.emailAddress)
                .textFieldStyle(.roundedBorder)

            SecureField("Password (min 6 characters)", text: $password)
                .textFieldStyle(.roundedBorder)

            if let msg = errorMessage {
                Text(msg)
                    .font(.caption)
                    .foregroundColor(.red)
                    .multilineTextAlignment(.center)
            }

            Button {
                handleAuth()
            } label: {
                if isLoading {
                    ProgressView()
                        .frame(maxWidth: .infinity)
                } else {
                    Text(isSignUp ? "Sign Up" : "Sign In")
                        .frame(maxWidth: .infinity)
                }
            }
            .buttonStyle(.borderedProminent)
            .disabled(!canSubmit)

            Button(isSignUp ? "Already have an account? Sign in" :
                               "New here? Create an account") {
                isSignUp.toggle()
                errorMessage = nil
            }
            .font(.caption)
            .padding(.top, 4)

            Spacer()
        }
        .padding()
    }

    private func handleAuth() {
        errorMessage = nil
        isLoading = true

        let action: (@escaping (Error?) -> Void) -> Void = { completion in
            if isSignUp {
                auth.signUp(email: email, password: password, completion: completion)
            } else {
                auth.signIn(email: email, password: password, completion: completion)
            }
        }

        action { error in
            isLoading = false
            if let error = error {
                errorMessage = error.localizedDescription
            } else {
                // success – AuthManager listener will switch to ContentView
            }
        }
    }
}

