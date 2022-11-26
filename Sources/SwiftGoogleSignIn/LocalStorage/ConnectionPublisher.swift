//
//  ConnectionPublisher.swift
//  SwiftGoogleSignIn Package
//
//  Created by Serhii Krotkih on 6/14/22.
//

import Foundation
import GoogleSignIn
import Combine

protocol UserSessionObservable: AnyObject {
    var userSession: CurrentValueSubject<UserSession?, Never> { get }
}

/// Observable Google user session data
class ConnectionPublisher: UserSessionObservable, ObservableObject {
    private let userSessionKey = UserSession.keyName
    private let localDataBase: DataPreservable

    // @Published var userSession: UserSession?

    var userSession: CurrentValueSubject<UserSession?, Never> = CurrentValueSubject(nil)
    
    init(localDataBase: DataPreservable) {
        self.localDataBase = localDataBase
    }
    
    func closeCurrentUserSession() {
        _currentUserSession = nil
    }
    
    var currentUserSession: UserSession? {
        if _currentUserSession == nil {
            _currentUserSession = localDataBase.restoreObject(key: userSessionKey)
        }
        return _currentUserSession
    }

    private var _currentUserSession: UserSession? {
        didSet {
            if _currentUserSession == nil {
                localDataBase.removeObject(key: userSessionKey)
            }
            userSession.send(_currentUserSession)
        }
    }

    func createNewUser(for googleUser: GIDGoogleUser) throws {
        do {
            let profile = UserProfile(googleUser)
            let remoteSession = UserAuthentication(googleUser)
            if profile == nil || remoteSession == nil {
                throw SignInError.failedUserData
            }
            let userSession = UserSession(profile: profile!, remoteSession: remoteSession!)
            try localDataBase.saveObject(userSession, key: userSessionKey)
            _currentUserSession = userSession
        } catch SwiftError.message(let error) {
            fatalError("\(error): Unexpected exception")
        } catch {
            throw SignInError.failedUserData
        }
    }
}

// MARK: - Restore previous session

extension ConnectionPublisher {
    func restorePreviousSession() async {
        do {
            if currentUserSession == nil {
                try createNewUser(for: await requestPreviousUser())
            }
        } catch SignInError.failedUserData {
            fatalError("Unexpected exception")
        } catch {
            fatalError("Unexpected exception")
        }
    }
    
    private func requestPreviousUser() async -> GIDGoogleUser {
        return await withCheckedContinuation { continuation in
            // source here: https://developers.google.com/identity/sign-in/ios/sign-in#3_attempt_to_restore_the_users_sign-in_state
            GIDSignIn.sharedInstance.restorePreviousSignIn { user, _ in
                guard let user = user else { return }
                continuation.resume(with: .success(user))
            }
        }
    }
}
