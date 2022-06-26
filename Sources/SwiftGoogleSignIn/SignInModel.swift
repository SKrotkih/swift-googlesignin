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

public struct GoogleUser: Codable {
    let userId: String
    let idToken: String
    let accessToken: String?
    let fullName: String
    let givenName: String
    let familyName: String
    let profilePicUrl: URL?
    let email: String

    init?(_ user: GIDGoogleUser) {
        if let userId = user.userID,
           let idToken = user.authentication.idToken {
            self.userId = userId
            self.idToken = idToken
            accessToken = user.authentication.accessToken
            fullName = user.profile?.name ?? ""
            givenName = user.profile?.givenName ?? ""
            familyName = user.profile?.familyName ?? ""
            profilePicUrl = user.profile?.imageURL(withDimension: 320)
            email = user.profile?.email ?? ""
        } else {
            return nil
        }
    }

    static var keyName: String {
        return String(describing: self)
    }
}

class SignInModel: SignInStorage, ObservableObject {
    private let userKey = GoogleUser.keyName

    @Published var user: GoogleUser?

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

    var userName: String {
        return currentUser?.fullName ?? "undefined"
    }

    var userInfo: String {
        return currentUser?.givenName ?? ""
    }

    var authIdToken: String? {
        return currentUser?.idToken
    }

    var authAccessToken: String? {
        return currentUser?.accessToken
    }

    var avatarURL: URL? {
        return currentUser?.profilePicUrl
    }

    func createLocalUserAccount(for user: GIDGoogleUser) throws {
        do {
            _currentUser = GoogleUser(user)
            if _currentUser == nil {
                throw SignInError.failedUserData
            }
            try LocalStorage.saveObject(_currentUser, key: userKey)
        } catch LocalError.message(let error) {
            fatalError("\(error): Unexpected exception")
        } catch {
            throw SignInError.failedUserData
        }
    }

    func deleteLocalUserAccount() {
        _currentUser = nil
    }
}
