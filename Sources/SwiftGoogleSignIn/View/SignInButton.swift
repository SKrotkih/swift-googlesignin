//
//  SignInButton.swift
//  SwiftGoogleSignIn Package
//
//  Created by Serhii Krotkykh on 6/14/22.
//

import SwiftUI
import GoogleSignInSwift

/// Google's sign-in button; place it on your log-in view. Tapping it calls `API.logIn()`.
public struct SignInButton: View {
    @Environment(\.colorScheme) private var colorScheme

    public init() {}

    public var body: some View {
        GoogleSignInButton(scheme: colorScheme == .dark ? .dark : .light, style: .standard) {
            API.logIn()
        }
    }
}
