//
//  UserSessionStore.swift
//  SwiftGoogleSignIn Package
//
//  Created by Serhii Krotkih on 6/14/22.
//

import Foundation
import GoogleSignIn
import Combine

class UserSessionStore: UserSessionObservable, ObservableObject {
    private let userSessionKey = UserSession.keyName

    @Published var userSession: UserSession?

    func closeCurrentUserSession() {
        _currentUserSession = nil
    }
    
    var currentUserSession: UserSession? {
        if _currentUserSession == nil {
            _currentUserSession = LocalStorage.restoreObject(key: userSessionKey)
        }
        return _currentUserSession
    }

    func restorePreviousSession() async {
        do {
            if currentUserSession == nil {
                let previousUser = await asyncRestorePreviousSession()
                try createUserSession(for: previousUser)
            }
        } catch SignInError.failedUserData {
            fatalError("Unexpected exception")
        } catch {
            fatalError("Unexpected exception")
        }
    }

    private var _currentUserSession: UserSession? {
        didSet {
            if _currentUserSession == nil {
                LocalStorage.removeObject(key: userSessionKey)
            }
            if oldValue != _currentUserSession {
                userSession = _currentUserSession
            }
        }
    }

    private func asyncRestorePreviousSession() async -> GIDGoogleUser {
        return await withCheckedContinuation { continuation in
            // source here: https://developers.google.com/identity/sign-in/ios/sign-in#3_attempt_to_restore_the_users_sign-in_state
            GIDSignIn.sharedInstance.restorePreviousSignIn { user, _ in
                guard let user = user else { return }
                continuation.resume(with: .success(user))
            }
        }
    }

    func createUserSession(for user: GIDGoogleUser) throws {
        do {
            let profile = UserProfile(user)
            let remoteSession = UserAuthentification(user)
            if profile == nil || remoteSession == nil {
                throw SignInError.failedUserData
            }
            let userSession = UserSession(profile: profile!, remoteSession: remoteSession!)
            try LocalStorage.saveObject(userSession, key: userSessionKey)
            _currentUserSession = userSession
        } catch SwiftError.message(let error) {
            fatalError("\(error): Unexpected exception")
        } catch {
            throw SignInError.failedUserData
        }
    }
}
