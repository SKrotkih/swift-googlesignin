//
//  GoogleConfigurator.swift
//  SwiftGoogleSignIn Package
//
//  Created by Serhii Krotkih on 6/14/22.
//

import Foundation
import GoogleSignIn

protocol SignInConfigurator {
    var signInConfig: GIDConfiguration { get }
}

class GoogleConfigurator: SignInConfigurator {

    public var signInConfig: GIDConfiguration {
        return GIDConfiguration(clientID: clientID)
    }

    lazy fileprivate var clientID: String = {
        return getClentID()
    }()

    private func getClentID() -> String {
        let key = "CLIENT_ID"
        if let plist = LocalStorage.getPlist("Info"), let id = plist[key] as? String, !id.isEmpty {
            return id
        } else if let plist = LocalStorage.getPlist("Config"), let id = plist[key] as? String, !id.isEmpty {
            return id
        } else {
            assert(false, "Please put your Client ID in info.plist as GoogleAPIClientID value")
        }
    }
}
