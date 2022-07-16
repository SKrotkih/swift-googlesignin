//
//  RemoteUserSession.swift
//  SwiftGoogleSignIn
//
//  Created by Serhii Krotkih on 6/14/22.
//

import Foundation
import GoogleSignIn

// Google API parameters store
public struct RemoteUserSession: Codable, Equatable {
    public let userId: String
    public let idToken: String
    public let accessToken: String?

    init?(_ googleUser: GIDGoogleUser) {
        if let userId = googleUser.userID,
           let idToken = googleUser.authentication.idToken {
            self.userId = userId
            self.idToken = idToken
            accessToken = googleUser.authentication.accessToken
        } else {
            return nil
        }
    }

    static var keyName: String {
        return String(describing: self)
    }
}

func ==(lUser: RemoteUserSession?, rUser: RemoteUserSession?) -> Bool {
    var isNotEqual = false
    switch (lUser, rUser) {
    case (nil, nil):
        break
    case (nil, _), (_, nil):
        isNotEqual = true
    default:
        if lUser?.userId != rUser?.userId {
            isNotEqual = true
        }
    }
    return !isNotEqual
}
