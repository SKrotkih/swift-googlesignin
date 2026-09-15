//
//  Error.swift
//  SwiftGoogleSignIn Package
//
//  Created by Serhii Krotkykh on 6/14/22.
//

import Foundation
import GoogleSignIn

/// Everything the package reports through ``SwiftGoogleSignInInterface/errorPublisher``.
///
/// Errors never terminate the session publisher: the user can retry sign-in after any of them.
public enum SignInError: Error {
    /// The user dismissed the Google sign-in sheet.
    case cancelled
    /// `restorePreviousSignIn` found nothing in the Keychain (first launch or after sign-out).
    /// Reported only when a restore was explicitly requested; the automatic restore at start-up is silent.
    case noPreviousSignIn
    /// The Google account signed in, but did not grant the scopes passed to `initialize(_:)`.
    /// Call ``SwiftGoogleSignInInterface/requestPermissions()`` to ask for them again.
    case missingScopes([String])
    /// The signed-in `GIDGoogleUser` lacks a user id or an id token.
    case invalidUserData
    /// Token refresh failed (revoked consent, offline, …). The session is cleared.
    case refreshFailed(any Error)
    /// Sign-out / disconnect failed.
    case signOutFailed(any Error)
    /// Any other error from the Google Sign-In SDK.
    case sdk(any Error)

    /// Maps an SDK error to the matching case.
    static func from(_ error: any Error) -> SignInError {
        guard let sdkError = error as? GIDSignInError else { return .sdk(error) }
        switch sdkError.code {
        case .canceled:            return .cancelled
        case .hasNoAuthInKeychain: return .noPreviousSignIn
        default:                   return .sdk(error)
        }
    }
}

extension SignInError: LocalizedError {
    public var errorDescription: String? {
        switch self {
        case .cancelled:
            return "Sign-in was cancelled."
        case .noPreviousSignIn:
            return "The user has not signed in before or has since signed out."
        case .missingScopes(let scopes):
            return "The Google account did not grant the required permissions: \(scopes.joined(separator: ", "))."
        case .invalidUserData:
            return "Google returned an account without a user id or id token. Please try again."
        case .refreshFailed(let error):
            return "Could not refresh the Google access token: \(error.localizedDescription)"
        case .signOutFailed(let error):
            return "Sign-out failed: \(error.localizedDescription)"
        case .sdk(let error):
            return error.localizedDescription
        }
    }
}
