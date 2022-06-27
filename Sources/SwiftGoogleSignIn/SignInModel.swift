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

// Local user profile information

public class SignInModel: SignInStorage, ObservableObject {
    private let userKey = GoogleUser.keyName

    @Published public var user: GoogleUser?

    private var _currentUser: GoogleUser? {
        didSet {
            if _currentUser == nil {
                LocalStorage.removeObject(key: userKey)
            }
            user = _currentUser
        }
    }

    private var currentUser: GoogleUser? {
        if _currentUser == nil {
            if let currentGoogleUser = GIDSignIn.sharedInstance.currentUser {
                _currentUser = GoogleUser(currentGoogleUser)
            } else {
                _currentUser = LocalStorage.restoreObject(key: userKey)
            }
        }
        return _currentUser
    }

    // MARK: - Interface implementtation
    
    public var userName: String {
        return currentUser?.fullName ?? "undefined"
    }

    public var userInfo: String {
        return currentUser?.givenName ?? ""
    }

    public var authIdToken: String? {
        return currentUser?.idToken
    }

    public var authAccessToken: String? {
        return currentUser?.accessToken
    }

    public var avatarURL: URL? {
        return currentUser?.profilePicUrl
    }

    public func createUserAccount(for user: GIDGoogleUser) throws {
        do {
            _currentUser = GoogleUser(user)
            if _currentUser == nil {
                throw SignInError.failedUserData
            }
            try LocalStorage.saveObject(_currentUser, key: userKey)
        } catch SwiftError.message(let error) {
            fatalError("\(error): Unexpected exception")
        } catch {
            throw SignInError.failedUserData
        }
    }

    public func deleteLocalUserAccount() {
        _currentUser = nil
    }
}
