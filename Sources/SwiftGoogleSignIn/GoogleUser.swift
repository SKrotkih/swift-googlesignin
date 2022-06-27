//
//  File.swift
//  
//
//  Created by Sergey Krotkih on 6/27/22.
//

import Foundation
import GoogleSignIn

public struct GoogleUser: Codable {
    public let userId: String
    public let idToken: String
    public let accessToken: String?
    public let fullName: String
    public let givenName: String
    public let familyName: String
    public let profilePicUrl: URL?
    public let email: String

    init?(_ user: GIDGoogleUser) {
        if let userId = user.userID,
           let idToken = user.authentication.idToken {
            self.userId = userId
            self.idToken = idToken
            accessToken = user.authentication.accessToken
            fullName = user.profile?.name ?? ""
            givenName = user.profile?.givenName ?? ""
            familyName = user.profile?.familyName ?? ""
            profilePicUrl = user.profile?.imageURL(withDimension: 320)
            email = user.profile?.email ?? ""
        } else {
            return nil
        }
    }

    static var keyName: String {
        return String(describing: self)
    }
}
