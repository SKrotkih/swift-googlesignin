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
    private let userKey = GoogleUser.keyName

    public init() {}
    
    @Published public var user: GoogleUser?

    public func deleteLocalUserAccount() {
        _currentUser = nil
    }

    private var _currentUser: GoogleUser? {
        didSet {
            if _currentUser == nil {
                LocalStorage.removeObject(key: userKey)
            }
            if oldValue != _currentUser {
                user = _currentUser
            }
        }
    }
    
    var currentUser: GoogleUser? {
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
}
