//
//  UserSession.swift
//  
//
//  Created by Serhii Krotkykh on 7/18/22.
//

import Foundation

/// The main structure with the User's account and connection info
public struct UserSession {
    
    // MARK: - Properties
    public let profile: UserProfile?
    public let remoteSession: UserAuthentication?
    
    // MARK: - Methods
    public init(profile: UserProfile? = nil, remoteSession: UserAuthentication? = nil) {
        self.profile = profile
        self.remoteSession = remoteSession
    }

    public var isConnected: Bool {
        return profile != nil && remoteSession != nil
    }

    static var empty: UserSession {
        return UserSession()
    }
}

extension UserSession: Equatable {
    static public func ==(lhs: UserSession, rhs: UserSession) -> Bool {
        return lhs.profile?.userId == rhs.profile?.userId &&
        lhs.remoteSession?.accessToken == rhs.remoteSession?.accessToken
    }
}
