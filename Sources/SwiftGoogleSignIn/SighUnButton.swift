//
//  File.swift
//  
//  Created by Serhii Krotkykh on 6/27/22.
//

import SwiftUI
import GoogleSignInSwift

/// SwiftUI content view for the Google Sign In
public struct SignInButton: View {
    public init() { }
    
    public var body: some View {
        // https://developers.google.com/identity/sign-in/ios/sign-in#4_add_a_google_sign-in_button
        GoogleSignInButton(scheme: .dark,
                           style: .standard,
                           action: {
            session.interactor?.signIn()
        })
    }
}
