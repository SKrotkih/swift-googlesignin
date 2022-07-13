//
//  SignInModel.swift
//  SwiftGoogleSignIn
//
//  Created by Serhii Krotkih on 6/14/22.
//

import Foundation
import GoogleSignIn
import Combine
import SwiftUI

public class SignInModel: UserObservable, ObservableObject {
    private let userProfileKey = UserProfile.keyName
    private let userSessionKey = RemoteUserSession.keyName

    public init() {}
    
    @Published public var userProfile: UserProfile?
    @Published public var remoteUserSession: RemoteUserSession?

    public func deleteLocalUserAccount() {
        _currentUserProfile = nil
    }

    private var _currentUserProfile: UserProfile? {
        didSet {
            if _currentUserProfile == nil {
                LocalStorage.removeObject(key: userProfileKey)
            }
            if oldValue != _currentUserProfile {
                userProfile = _currentUserProfile
            }
        }
    }
    
    private var _currentRemoteUserSession: RemoteUserSession?
    
    var currentUser: UserProfile? {
        if _currentUserProfile == nil {
            if let currentGoogleUser = GIDSignIn.sharedInstance.currentUser {
                _currentUserProfile = UserProfile(currentGoogleUser)
                _currentRemoteUserSession = RemoteUserSession(currentGoogleUser)
            } else {
                _currentUserProfile = LocalStorage.restoreObject(key: userProfileKey)
                _currentRemoteUserSession = LocalStorage.restoreObject(key: userSessionKey)
            }
        }
        return _currentUserProfile
    }

    func createUserAccount(for user: GIDGoogleUser) throws {
        do {
            let newUser = UserProfile(user)
            let newUserSession = RemoteUserSession(user)
            if newUser == nil {
                throw SignInError.failedUserData
            }
            try LocalStorage.saveObject(newUser, key: userProfileKey)
            try LocalStorage.saveObject(newUserSession, key: userSessionKey)
            _currentUserProfile = newUser
            _currentRemoteUserSession = newUserSession
        } catch SwiftError.message(let error) {
            fatalError("\(error): Unexpected exception")
        } catch {
            throw SignInError.failedUserData
        }
    }
}
