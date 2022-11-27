//
//  UserProfile.swift
//  SwiftGoogleSignIn Package
//
//  Created by Serhii Krotkykh on 6/14/22.
//

import Foundation
import GoogleSignIn

public struct UserProfile: Codable, Equatable {
    public let userId: String
    public let fullName: String
    public let givenName: String
    public let familyName: String
    public let profilePicUrl: URL?
    public let email: String

    init?(_ user: GIDGoogleUser) {
        if let userId = user.userID {
            self.userId = userId
            fullName = user.profile?.name ?? ""
            givenName = user.profile?.givenName ?? ""
            familyName = user.profile?.familyName ?? ""
            profilePicUrl = user.profile?.imageURL(withDimension: 320)
            email = user.profile?.email ?? ""
        } else {
            return nil
        }
    }
}

public func ==(lUser: UserProfile?, rUser: UserProfile?) -> Bool {
    var notEqual = false
    switch (lUser, rUser) {
    case (nil, nil):
        break
    case (nil, _), (_, nil):
        notEqual = true
    default:
        if lUser?.userId != rUser?.userId {
            notEqual = true
        }
    }
    return !notEqual
}
