//
//  UserSession.swift
//  
//
//  Created by Sergey Krotkih on 7/18/22.
//

import Foundation

public class UserSession: Codable {
    
    // MARK: - Properties
    public let profile: UserProfile
    public let remoteSession: UserAuthentication
    
    // MARK: - Methods
    public init(profile: UserProfile, remoteSession: UserAuthentication) {
        self.profile = profile
        self.remoteSession = remoteSession
    }
    
    static var keyName: String {
        return String(describing: self)
    }
}

extension UserSession: Equatable {
    static public func ==(lhs: UserSession, rhs: UserSession) -> Bool {
        return lhs.profile.userId == rhs.profile.userId &&
        lhs.remoteSession.accessToken == rhs.remoteSession.accessToken
    }
}
