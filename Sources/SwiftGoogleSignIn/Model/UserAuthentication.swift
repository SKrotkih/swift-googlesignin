//
//  UserAuthentication.swift
//  SwiftGoogleSignIn Package
//
//  Created by Serhii Krotkykh on 6/14/22.
//

import Foundation
import GoogleSignIn

/// Google API credentials of the signed-in user. Part of ``UserSession``.
public struct UserAuthentication: Codable, Equatable, Sendable {
    public let userId: String
    public let idToken: String
    /// OAuth 2.0 access token for Google APIs. Refresh it with
    /// ``SwiftGoogleSignInInterface/refreshTokensIfNeeded()`` before long-running work.
    public let accessToken: String
    /// When `accessToken` stops being accepted by Google APIs.
    public let accessTokenExpirationDate: Date?
    /// Scopes the user actually granted.
    public let grantedScopes: [String]

    public init(userId: String,
                idToken: String,
                accessToken: String,
                accessTokenExpirationDate: Date? = nil,
                grantedScopes: [String] = []) {
        self.userId = userId
        self.idToken = idToken
        self.accessToken = accessToken
        self.accessTokenExpirationDate = accessTokenExpirationDate
        self.grantedScopes = grantedScopes
    }

    init?(_ googleUser: GIDGoogleUser) {
        guard let userId = googleUser.userID,
              let idToken = googleUser.idToken?.tokenString else { return nil }
        self.init(userId: userId,
                  idToken: idToken,
                  accessToken: googleUser.accessToken.tokenString,
                  accessTokenExpirationDate: googleUser.accessToken.expirationDate,
                  grantedScopes: googleUser.grantedScopes ?? [])
    }

    /// `true` when the access token is missing or expires within `leeway` seconds.
    public func isAccessTokenExpiring(within leeway: TimeInterval = 60) -> Bool {
        guard let date = accessTokenExpirationDate else { return false }
        return date.timeIntervalSinceNow < leeway
    }
}
