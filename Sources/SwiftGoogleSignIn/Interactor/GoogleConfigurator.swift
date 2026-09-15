//
//  GoogleConfigurator.swift
//  SwiftGoogleSignIn Package
//
//  Created by Serhii Krotkykh on 6/14/22.
//

import GoogleSignIn

protocol SignInConfigurator {
    var signInConfig: GIDConfiguration { get }
}

/// Builds the `GIDConfiguration` from the client id stored in the app's Info.plist / Config.plist.
final class GoogleConfigurator: SignInConfigurator {
    private let localStorage: ConfigurableData

    init(localStorage: ConfigurableData) {
        self.localStorage = localStorage
    }

    private(set) lazy var signInConfig = GIDConfiguration(clientID: localStorage.clientID)
}
