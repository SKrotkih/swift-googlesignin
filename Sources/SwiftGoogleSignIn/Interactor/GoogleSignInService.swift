//
//  GoogleSignInService.swift
//  SwiftGoogleSignIn Package
//
//  Created by Serhii Krotkykh on 6/14/22.
//

import Foundation
import UIKit
import GoogleSignIn
import Combine

/// Wraps `GIDSignIn` (Google Sign-In SDK 8) and publishes the session and errors separately,
/// so an error never terminates the session stream.
@MainActor
final class GoogleSignInService {
    /// Current session; `.empty` while signed out. Never fails.
    let userSession = CurrentValueSubject<UserSession, Never>(.empty)
    /// One event per failed operation.
    let errors = PassthroughSubject<SignInError, Never>()

    private let configurator: SignInConfigurator
    private let requiredScopes: [String]

    init(configurator: SignInConfigurator, scopePermissions: [String]?) {
        self.configurator = configurator
        self.requiredScopes = scopePermissions ?? []
        GIDSignIn.sharedInstance.configuration = configurator.signInConfig
        Task { await restorePreviousSession(reportMissing: false) }
    }

    // MARK: - Sign in / out

    /// Presents the Google sign-in sheet, asking for the required API scopes up front (one consent screen).
    func signIn(presenting viewController: UIViewController) {
        Task {
            do {
                let result = try await GIDSignIn.sharedInstance.signIn(
                    withPresenting: viewController,
                    hint: nil,
                    additionalScopes: requiredScopes
                )
                publish(result.user)
            } catch {
                errors.send(SignInError.from(error))
            }
        }
    }

    /// Signs out and disconnects the account from the app (Google's recommended clean-up).
    func signOut() {
        GIDSignIn.sharedInstance.signOut()
        userSession.send(.empty)
        Task {
            do {
                try await GIDSignIn.sharedInstance.disconnect()
            } catch {
                // Already signed out locally; disconnect just failed to reach Google (e.g. offline).
                errors.send(.signOutFailed(error))
            }
        }
    }

    func openUrl(_ url: URL) -> Bool {
        GIDSignIn.sharedInstance.handle(url)
    }

    // MARK: - Scopes

    /// Asks the signed-in user for the scopes they have not granted yet.
    func addMissingScopes(presenting viewController: UIViewController) {
        guard let user = GIDSignIn.sharedInstance.currentUser else {
            errors.send(.noPreviousSignIn)
            return
        }
        let missing = missingScopes(for: user)
        guard !missing.isEmpty else {
            publish(user)
            return
        }
        Task {
            do {
                let result = try await user.addScopes(missing, presenting: viewController)
                publish(result.user)
            } catch {
                errors.send(SignInError.from(error))
            }
        }
    }

    private func missingScopes(for user: GIDGoogleUser) -> [String] {
        let granted = Set(user.grantedScopes ?? [])
        return requiredScopes.filter { !granted.contains($0) }
    }

    // MARK: - Restore & refresh

    /// Restores the Keychain session. A session that lacks the required scopes is dropped so the
    /// app shows the sign-in screen and a fresh consent is requested.
    func restorePreviousSession(reportMissing: Bool) async {
        do {
            let user = try await GIDSignIn.sharedInstance.restorePreviousSignIn()
            publish(user)
        } catch {
            let mapped = SignInError.from(error)
            if case .noPreviousSignIn = mapped, !reportMissing { return }
            errors.send(mapped)
        }
    }

    /// Refreshes the access/id tokens if they are expired or about to expire, and republishes the session.
    func refreshTokensIfNeeded() async throws -> UserSession {
        guard let user = GIDSignIn.sharedInstance.currentUser else {
            throw SignInError.noPreviousSignIn
        }
        do {
            let fresh = try await user.refreshTokensIfNeeded()
            guard let session = makeSession(fresh) else { throw SignInError.invalidUserData }
            userSession.send(session)
            return session
        } catch let error as SignInError {
            throw error
        } catch {
            let mapped = SignInError.refreshFailed(error)
            GIDSignIn.sharedInstance.signOut()
            userSession.send(.empty)
            errors.send(mapped)
            throw mapped
        }
    }

    // MARK: - Publishing

    /// Publishes the user as the current session, or reports why it cannot be used.
    private func publish(_ user: GIDGoogleUser) {
        let missing = missingScopes(for: user)
        guard missing.isEmpty else {
            GIDSignIn.sharedInstance.signOut()
            userSession.send(.empty)
            errors.send(.missingScopes(missing))
            return
        }
        guard let session = makeSession(user) else {
            errors.send(.invalidUserData)
            return
        }
        userSession.send(session)
    }

    private func makeSession(_ user: GIDGoogleUser) -> UserSession? {
        guard let profile = UserProfile(user), let auth = UserAuthentication(user) else { return nil }
        return UserSession(profile: profile, remoteSession: auth)
    }
}
