//
//  LoginView.swift
//  lostNfoUnd
//
//  Created by Neel Chandwani on 3/3/25.
//

import SwiftUI
import FirebaseAuth

struct LoginView: View {
    @State private var email: String = ""
    @State private var password: String = ""
    @State private var errorMessage: String = ""
    @Environment(\.presentationMode) var presentationMode
    var onLoginSuccess: () -> Void // Closure to notify parent view

    var body: some View {
        VStack(spacing: 20) {
            Text("Login")
                .font(.largeTitle)
                .bold()

            TextField("Email", text: $email)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .autocapitalization(.none)
                .keyboardType(.emailAddress)

            SecureField("Password", text: $password)
                .textFieldStyle(RoundedBorderTextFieldStyle())

            if !errorMessage.isEmpty {
                Text(errorMessage)
                    .foregroundColor(.red)
            }

            Button("Login") {
                loginUser()
            }
            .padding()
            .background(Color.blue)
            .foregroundColor(.white)
            .cornerRadius(10)

            Spacer()
        }
        .padding()
    }

    func loginUser() {
        Auth.auth().signIn(withEmail: email, password: password) { result, error in
            if let error = error {
                errorMessage = error.localizedDescription
            } else {
                print("User logged in successfully!")
                onLoginSuccess() // Notify parent view of successful login
                presentationMode.wrappedValue.dismiss() // Dismiss the login view
            }
        }
    }
}
