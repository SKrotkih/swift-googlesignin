//
//  UserProfile.swift
//  SwiftGoogleSignIn Package
//
//  Created by Serhii Krotkykh on 6/14/22.
//

import Foundation
import GoogleSignIn

/// Public profile of the signed-in Google account. Part of ``UserSession``.
public struct UserProfile: Codable, Equatable, Sendable {
    public let userId: String
    public let fullName: String
    public let givenName: String
    public let familyName: String
    public let profilePicUrl: URL?
    public let email: String

    public init(userId: String,
                fullName: String = "",
                givenName: String = "",
                familyName: String = "",
                profilePicUrl: URL? = nil,
                email: String = "") {
        self.userId = userId
        self.fullName = fullName
        self.givenName = givenName
        self.familyName = familyName
        self.profilePicUrl = profilePicUrl
        self.email = email
    }

    init?(_ user: GIDGoogleUser) {
        guard let userId = user.userID else { return nil }
        self.init(userId: userId,
                  fullName: user.profile?.name ?? "",
                  givenName: user.profile?.givenName ?? "",
                  familyName: user.profile?.familyName ?? "",
                  profilePicUrl: user.profile?.imageURL(withDimension: 320),
                  email: user.profile?.email ?? "")
    }
}
