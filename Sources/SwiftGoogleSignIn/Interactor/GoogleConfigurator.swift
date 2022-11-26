//
//  GoogleConfigurator.swift
//  SwiftGoogleSignIn Package
//
//  Created by Serhii Krotkih on 6/14/22.
//
import GoogleSignIn

protocol SignInConfigurator {
    var signInConfig: GIDConfiguration { get }
}

/**
 Use this config for the GoogleSignIn's signIn method
 */
class GoogleConfigurator: SignInConfigurator {
    private let localStorage: ConfigurableData

    init(localStorage: ConfigurableData) {
        self.localStorage = localStorage
    }

    var signInConfig: GIDConfiguration {
        return GIDConfiguration(clientID: clientID)
    }

    lazy fileprivate var clientID: String = {
        return localStorage.clientID
    }()
}
