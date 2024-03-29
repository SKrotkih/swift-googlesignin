//
//  UserAuthentication.swift
//  SwiftGoogleSignIn Package
//
//  Created by Serhii Krotkykh on 6/14/22.
//

import Foundation
import GoogleSignIn

/// Google API parameters store
/// It's a part of the UserSession structure data
public struct UserAuthentication: Codable, Equatable {
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
}

func ==(lUser: UserAuthentication?, rUser: UserAuthentication?) -> Bool {
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
