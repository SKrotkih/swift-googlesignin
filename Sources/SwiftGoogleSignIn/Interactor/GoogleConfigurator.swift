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

/**
 Client should configure the Google Sign-In for iOS and macOS package before using
 */
class GoogleConfigurator: SignInConfigurator {
    private let localStorage: ConfigurableData

    init(localStorage: ConfigurableData) {
        self.localStorage = localStorage
    }

    var signInConfig: GIDConfiguration {
        // it does not make sence to cache the configuration on my opinion
        return GIDConfiguration(clientID: clientID)
    }

    // We use the client id from the config plist file in main bundle
    lazy fileprivate var clientID: String = {
        return localStorage.clientID
    }()
}
