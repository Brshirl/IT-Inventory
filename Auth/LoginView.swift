// LoginView.swift
// Inventory
//
// Created by Brett Shirley on 6/29/23.

import SwiftUI
import AuthenticationServices

struct LoginView: View {
    var body: some View {
        VStack {
            Image(systemName: "GECOLOGO")
                .font(.system(size: 100))
                .padding(.bottom, 30)

            SignInWithAppleButtonView { result in
                switch result {
                case .success(let user):
                    print("Successfully signed in with Apple: \(user)")
                    // Handle successful sign-in, e.g., update UI or navigate to the next screen
                case .failure(let error):
                    print("Error signing in with Apple: \(error)")
                    // Handle error, e.g., show an alert to the user
                }
            }
            .frame(width: 280, height: 50)
        }
        .padding()
    }
}


struct SignInWithAppleButtonView: UIViewRepresentable {   
    var onCompletion: (Result<String, Error>) -> Void

    func makeUIView(context: Context) -> ASAuthorizationAppleIDButton {
        let button = ASAuthorizationAppleIDButton(type: .signIn, style: .black)
        button.addTarget(context.coordinator, action: #selector(context.coordinator.handleSignInWithAppleButtonPress), for: .touchUpInside)
        return button
    }

    func updateUIView(_ uiView: ASAuthorizationAppleIDButton, context: Context) {}

    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }

    class Coordinator: NSObject, ASAuthorizationControllerDelegate, ASAuthorizationControllerPresentationContextProviding {
        var parent: SignInWithAppleButtonView

        init(_ parent: SignInWithAppleButtonView) {
            self.parent = parent
        }

        @objc func handleSignInWithAppleButtonPress() {
            let request = ASAuthorizationAppleIDProvider().createRequest()
            request.requestedScopes = [.fullName, .email]

            let controller = ASAuthorizationController(authorizationRequests: [request])
            controller.delegate = self
            controller.presentationContextProvider = self
            controller.performRequests()
        }

        func authorizationController(controller: ASAuthorizationController, didCompleteWithAuthorization authorization: ASAuthorization) {
            if let appleIDCredential = authorization.credential as? ASAuthorizationAppleIDCredential {
                let userIdentifier = appleIDCredential.user
                self.parent.onCompletion(.success(userIdentifier))
            }
        }

        func authorizationController(controller: ASAuthorizationController, didCompleteWithError error: Error) {
            self.parent.onCompletion(.failure(error))
        }

        func presentationAnchor(for controller: ASAuthorizationController) -> ASPresentationAnchor {
            return UIApplication.shared.windows.first!
        }
    }
}

