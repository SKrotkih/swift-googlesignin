//
//  UserSession.swift
//  
//
//  Created by Serhii Krotkykh on 7/18/22.
//

import Foundation

public struct UserSession: Codable {
    
    // MARK: - Properties
    public let profile: UserProfile?
    public let remoteSession: UserAuthentication?
    public let connectionError: String?
    
    // MARK: - Methods
    public init(profile: UserProfile, remoteSession: UserAuthentication) {
        self.profile = profile
        self.remoteSession = remoteSession
        self.connectionError = nil
    }

    public init(error: String?) {
        self.profile = nil
        self.remoteSession = nil
        self.connectionError = error
    }
    
    static var keyName: String {
        return String(describing: self)
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
