// LoginView.swift
// Inventory
//
// Created by Brett Shirley on 6/29/23.

import SwiftUI
import FirebaseAuth


struct LoginView: View {
    @AppStorage("uid") var userID: String = ""
    
    @State private var email: String = ""
    @State private var password: String = ""
    @State private var isLoggedIn: Bool = false // Track login state
    
    private func isValidEmail(_ email: String) -> Bool {
        // Validate email using regular expression
        let emailRegex = NSPredicate(format: "SELF MATCHES %@", "[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,}")
        return emailRegex.evaluate(with: email)
    }

    private func isValidPassword(_ password: String) -> Bool {
        // Minimum 6 characters long
        // At least 1 uppercase character
        // At least 1 special character
        let passwordRegex = NSPredicate(format: "SELF MATCHES %@", "^(?=.*[a-z])(?=.*[$@$#!%*?&])(?=.*[A-Z]).{6,}$")
        return passwordRegex.evaluate(with: password)
    }

    var body: some View {
        NavigationView {
            VStack {
                Spacer()
                TextFieldWithValidation(systemName: "mail", placeholder: "Email", text: $email, isValid: isValidEmail)
                SecureFieldWithValidation(systemName: "lock", placeholder: "Password", text: $password, isValid: isValidPassword)
                
                Button("Sign In") {
                    signIn()
                }
                .buttonStyle(FilledButtonStyle())
                .padding()
                
                Spacer()
            }
            .fullScreenCover(isPresented: $isLoggedIn) {
                NavigationView {
                    ContentView()
                }
            }
            .navigationBarHidden(true)
        }
        .navigationViewStyle(StackNavigationViewStyle())
    }
    
    // Button action to perform sign-in
    func signIn() {
        Auth.auth().signIn(withEmail: email, password: password) { authResult, error in
            if let error = error {
                print(error)
                return
            }
            
            if let authResult = authResult {
                print(authResult.user.uid)
                withAnimation {
                    userID = authResult.user.uid
                    isLoggedIn = true
                }
            }
        }
    }
}


