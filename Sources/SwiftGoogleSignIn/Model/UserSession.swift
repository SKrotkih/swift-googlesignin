//
//  UserSession.swift
//  SwiftGoogleSignIn Package
//
//  Created by Serhii Krotkykh on 7/18/22.
//

import Foundation

/// The signed-in account and its Google API credentials. `UserSession()` means "signed out".
public struct UserSession: Equatable, Sendable {
    public let profile: UserProfile?
    public let remoteSession: UserAuthentication?

    public init(profile: UserProfile? = nil, remoteSession: UserAuthentication? = nil) {
        self.profile = profile
        self.remoteSession = remoteSession
    }

    public var isConnected: Bool {
        profile != nil && remoteSession != nil
    }

    /// Shortcut for `remoteSession?.accessToken`.
    public var accessToken: String? { remoteSession?.accessToken }

    public static let empty = UserSession()
}
