//
//  UserSession.swift
//  
//
//  Created by Serhii Krotkykh on 7/18/22.
//

import Foundation

public struct UserSession {
    
    // MARK: - Properties
    public let profile: UserProfile?
    public let remoteSession: UserAuthentication?
    public let error: SwiftError?
    
    // MARK: - Methods
    public init(profile: UserProfile, remoteSession: UserAuthentication) {
        self.profile = profile
        self.remoteSession = remoteSession
        self.error = nil
    }

    public init(error: SwiftError?) {
        self.profile = nil
        self.remoteSession = nil
        self.error = error
    }
    
    public var isConnected: Bool {
        return profile != nil && remoteSession != nil
    }

    static var empty: UserSession {
        return UserSession(error: nil)
    }
}

extension UserSession: Equatable {
    static public func ==(lhs: UserSession, rhs: UserSession) -> Bool {
        return lhs.profile?.userId == rhs.profile?.userId &&
        lhs.remoteSession?.accessToken == rhs.remoteSession?.accessToken
    }
}
