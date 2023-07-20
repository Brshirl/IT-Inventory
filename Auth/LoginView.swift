// LoginView.swift
// Inventory
//
// Created by Brett Shirley on 6/29/23.

import SwiftUI
import FirebaseAuth
import AuthenticationServices

struct SignInWithAppleButtonViewRep: UIViewRepresentable {
    
    let type: ASAuthorizationAppleIDButton.ButtonType
    let style: ASAuthorizationAppleIDButton.Style
    
    func makeUIView(context: Context) -> ASAuthorizationAppleIDButton {
        ASAuthorizationAppleIDButton(authorizationButtonType: type, authorizationButtonStyle: style)
    }
    
    func updateUIView(_ uiView: ASAuthorizationAppleIDButton, context: Context) {
        
    }
}

struct LoginView: View {
    @StateObject var loginData = Apple()
    @AppStorage("uid") var userID: String = ""
    @AppStorage("email") var email: String = ""
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
        // Password!
        let passwordRegex = NSPredicate(format: "SELF MATCHES %@", "^(?=.*[a-z])(?=.*[$@$#!%*?&])(?=.*[A-Z]).{6,}$")
        return passwordRegex.evaluate(with: password)
    }

    var body: some View {
        NavigationView {
            VStack {
                Spacer()
                Image("GECOLOGO")
                    .resizable()
                    .scaledToFit()
                TextFieldWithValidation(systemName: "mail", placeholder: "Email", text: $email, isValid: isValidEmail)
                SecureFieldWithValidation(systemName: "lock", placeholder: "Password", text: $password, isValid: isValidPassword)
                
                Button("Sign In") {
                    signIn()
                }
                .buttonStyle(FilledButtonStyle())
                .padding()
                
                Spacer()
                Spacer()
                SignInWithAppleButton { (request) in
                    loginData.nonce = randomNonceString()
                    request.requestedScopes = [.email, .fullName]
                    request.nonce = sha256(loginData.nonce)
                } onCompletion: { (result) in
                    switch result {
                    case .success(let user):
                        print("Success")
                        guard let credential = user.credential as? ASAuthorizationAppleIDCredential else {
                            print("Error with Firebase")
                            return
                        }
                        loginData.authenticate(credential: credential)
                        
                    case .failure(let error):
                        print(error.localizedDescription)
                    }
                }
                .signInWithAppleButtonStyle(.black)
                .frame(height: 55)
                .clipShape(Capsule())
                .padding(.horizontal, 30)
                .offset(y: -70)

                // End of code for button placement
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
