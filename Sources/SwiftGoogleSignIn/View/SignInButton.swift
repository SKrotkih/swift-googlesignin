//
//  SignInButton.swift
//  SwiftGoogleSignIn Package
//
//  Created by Serhii Krotkykh on 6/14/22.
//

import SwiftUI
import GoogleSignInSwift

/// SwiftUI content view for the Google Sign In button
/// Just place this button on your LogIn view
public struct SignInButton: View {
    public init() { }
    
    @Environment(\.colorScheme) var colorSheme: ColorScheme
    
    public var body: some View {
        // https://developers.google.com/identity/sign-in/ios/sign-in#4_add_a_google_sign-in_button
        GoogleSignInButton(scheme: self.colorSheme == .dark ? .dark : .light,
                           style: .standard,
                           action: {
            API.logIn()
        })
    }
}
