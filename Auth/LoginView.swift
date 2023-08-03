// LoginView.swift
// Inventory
//
// Created by Brett Shirley on 6/29/23.

import SwiftUI
import FirebaseAuth
import AuthenticationServices
import CryptoKit

struct SignInWithAppleButtonViewRep: UIViewRepresentable {
    let type: ASAuthorizationAppleIDButton.ButtonType
    let style: ASAuthorizationAppleIDButton.Style

    func makeUIView(context: Context) -> ASAuthorizationAppleIDButton {
        ASAuthorizationAppleIDButton(authorizationButtonType: type, authorizationButtonStyle: style)
    }

    func updateUIView(_ uiView: ASAuthorizationAppleIDButton, context: Context) {

    }
}

fileprivate var currentNonce: String?

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

                // Add the "Sign in with Apple" button below the login button
                SignInWithAppleButtonViewRep(type: .signIn, style: .whiteOutline)
                    .frame(width: 200, height: 45)
                    .onTapGesture {
                        //startSignInWithAppleFlow(coordinator: signInCoordinator)
                    }

                Spacer()
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

//    //@available(iOS 13, *)
//    func startSignInWithAppleFlow() {
//        let nonce = randomNonceString()
//        currentNonce = nonce
//        let appleIdProvider = ASAuthorizationAppleIDProvider()
//        let request = appleIdProvider.createRequest()
//        request.requestedScopes = [.fullName, .email]
//        request.nonce = sha256(nonce)
//
//        let authroizationController = ASAuthorizationController(authorizationRequests: [request])
//        authroizationController.delegate = self
//        authroizationController.presentationContextProvider = self
//        authroizationController.performRequests()
//    }
//}

////@available(iOS 13, *)
//extension LoginView: ASAuthorizationControllerDelegate, ASAuthorizationControllerPresentationContextProviding {
//    func presentationAnchor(for controller: ASAuthorizationController) -> ASPresentationAnchor {
//        // Return the window or view controller from which you want to present the Sign In with Apple dialog
//        return UIApplication.shared.windows.first!
//    }
//
//    func authorizationController(controller: ASAuthorizationController, didCompleteWithAuthorization authorization: ASAuthorization) {
//        if let appleIDCredential = authorization.credential as? ASAuthorizationAppleIDCredential {
//            guard let nonce = currentNonce else {
//                fatalError("Invalid state: A login callback was received, but no login request was sent.")
//            }
//
//            guard let appleIDTokenData = appleIDCredential.identityToken else {
//                print("Unable to fetch identity token")
//                return
//            }
//
//            guard let appleIDToken = String(data: appleIDTokenData, encoding: .utf8) else {
//                print("Unable to convert identity token to string")
//                return
//            }
//
//            let credential = OAuthProvider.credential(withProviderID: "apple.com", idToken: appleIDToken, rawNonce: nonce)
//            signInWithCredential(credential)
//        }
//    }
//
//    func authorizationController(controller: ASAuthorizationController, didCompleteWithError error: Error) {
//        print("Sign In with Apple failed: \(error.localizedDescription)")
//    }
//
//    private func signInWithCredential(_ credential: OAuthCredential) {
//        Auth.auth().signIn(with: credential) { authResult, error in
//            if let error = error {
//                print("Firebase authentication failed: \(error.localizedDescription)")
//                return
//            }
//
//            if let authResult = authResult {
//                print("Sign In with Apple succeeded. User ID: \(authResult.user.uid)")
//                withAnimation {
//                    userID = authResult.user.uid
//                    isLoggedIn = true
//                }
//            }
//        }
//    }
}
