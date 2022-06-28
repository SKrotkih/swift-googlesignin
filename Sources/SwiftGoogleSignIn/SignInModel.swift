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

public class SignInModel: SignInStorage, ObservableObject {
    private let userKey = GoogleUser.keyName

    public init() {}
    
    @Published public var user: GoogleUser?

    private var _currentUser: GoogleUser? {
        didSet {
            if _currentUser == nil {
                LocalStorage.removeObject(key: userKey)
            }
            if isNotEqual(oldUser: oldValue, newUser: _currentUser) {
                user = _currentUser
            }
        }
    }

    private func isNotEqual(oldUser: GoogleUser?, newUser: GoogleUser?) -> Bool {
        let oldUserId: String? = oldUser?.userId
        let newUserId: String? = newUser?.userId
        var isNotEqual = false
        switch (oldUserId, newUserId) {
        case (nil, nil):
            break
        case (nil, _), (_, nil):
            isNotEqual = true
        default:
            if oldUserId != newUserId {
                isNotEqual = true
            }
        }
        return isNotEqual
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

    func createUserAccount(for user: GIDGoogleUser) throws {
        do {
            let newUser = GoogleUser(user)
            if newUser == nil {
                throw SignInError.failedUserData
            }
            try LocalStorage.saveObject(_currentUser, key: userKey)
            _currentUser = newUser
        } catch SwiftError.message(let error) {
            fatalError("\(error): Unexpected exception")
        } catch {
            throw SignInError.failedUserData
        }
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

    public func deleteLocalUserAccount() {
        _currentUser = nil
    }
}
