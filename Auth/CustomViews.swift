//
//  CustomViews.swift
//  Inventory
//
//  Created by Brett Shirley on 6/29/23.
//

import Foundation
import SwiftUI

// Custom text field with validation
struct TextFieldWithValidation: View {
    let systemName: String
    let placeholder: String
    @Binding var text: String
    let isValid: (String) -> Bool
    
    var body: some View {
        HStack {
            Image(systemName: systemName)
            TextField(placeholder, text: $text)
            
            Spacer()
            
            if !text.isEmpty {
                Image(systemName: isValid(text) ? "checkmark" : "xmark")
                    .fontWeight(.bold)
                    .foregroundColor(isValid(text) ? .green : .red)
            }
        }
        .padding()
        .overlay(
            RoundedRectangle(cornerRadius: 10)
                .stroke(lineWidth: 2)
                .foregroundColor(.black)
        )
        .padding()
    }
}

// Custom secure field with validation
struct SecureFieldWithValidation: View {
    let systemName: String
    let placeholder: String
    @Binding var text: String
    let isValid: (String) -> Bool
    
    var body: some View {
        HStack {
            Image(systemName: systemName)
            SecureField(placeholder, text: $text)
            
            Spacer()
            
//            if !text.isEmpty {
//                Image(systemName: isValid(text) ? "checkmark" : "xmark")
//                    .fontWeight(.bold)
//                    .foregroundColor(isValid(text) ? .green : .red)
//            }
        }
        .padding()
        .overlay(
            RoundedRectangle(cornerRadius: 10)
                .stroke(lineWidth: 2)
                .foregroundColor(.black)
        )
        .padding()
    }
}

// Custom button style
struct FilledButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration
            .label
            .foregroundColor(.white)
            .font(.title3)
            .bold()
            .frame(maxWidth: .infinity)
            .padding()
            .background(
                RoundedRectangle(cornerRadius: 10)
                    .fill(Color.black)
            )
            .padding(.horizontal)
    }
}


