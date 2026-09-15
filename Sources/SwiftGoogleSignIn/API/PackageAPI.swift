//
//  PackageAPI.swift
//  SwiftGoogleSignIn Package
//
//  Created by Serhii Krotkykh on 6/14/22.
//

import UIKit
import Combine

/// The package entry point. Main-actor bound, like the Google Sign-In SDK itself.
@MainActor
public let API: SwiftGoogleSignInInterface = PackageAPI()

/// The package public interface.
///
/// The session and the errors are separate streams: an error (cancelled sheet, missing scopes,
/// network failure) is delivered on ``errorPublisher`` and the session stream keeps going, so the
/// user can simply try again.
@MainActor
public protocol SwiftGoogleSignInInterface: AnyObject {
    /// Call once at start-up, before anything else, with the Google API scopes the app needs
    /// (`nil` or `[]` for plain sign-in). They are requested on the sign-in consent screen.
    func initialize(_ scopePermissions: [String]?)

    /// The current session (``UserSession/empty`` while signed out), then every change.
    var publisher: AnyPublisher<UserSession, Never> { get }
    /// One event per failed operation. See ``SignInError``.
    var errorPublisher: AnyPublisher<SignInError, Never> { get }
    /// The latest value of ``publisher``.
    var session: UserSession { get }

    /// The view controller Google Sign-In presents its sheet from. Set before ``logIn()``.
    var presentingViewController: UIViewController? { get set }

    /// Presents the Google sign-in sheet (``SignInButton`` calls this).
    func logIn()
    /// Signs out and disconnects the account. The session becomes ``UserSession/empty``.
    func logOut()
    /// Asks the signed-in user for the scopes from `initialize(_:)` they have not granted yet.
    func requestPermissions()
    /// Re-runs the Keychain restore; a missing previous sign-in is reported on ``errorPublisher``.
    func restorePreviousSignIn() async
    /// Refreshes expired (or about to expire) tokens and returns the updated session.
    /// Use it from a `TokenProvider` when an API call answers 401.
    @discardableResult
    func refreshTokensIfNeeded() async throws -> UserSession

    /// Forward `application(_:open:options:)` / `onOpenURL` here.
    func openUrl(_ url: URL) -> Bool
}

@MainActor
final class PackageAPI: SwiftGoogleSignInInterface {
    private var scopePermissions: [String]?

    public func initialize(_ scopePermissions: [String]?) {
        self.scopePermissions = scopePermissions
    }

    private lazy var interactor: GoogleSignInService = {
        let configurator = GoogleConfigurator(localStorage: LocalStorage())
        return GoogleSignInService(configurator: configurator, scopePermissions: scopePermissions)
    }()

    public var publisher: AnyPublisher<UserSession, Never> {
        interactor.userSession.eraseToAnyPublisher()
    }

    public var errorPublisher: AnyPublisher<SignInError, Never> {
        interactor.errors.eraseToAnyPublisher()
    }

    public var session: UserSession {
        interactor.userSession.value
    }

    public var presentingViewController: UIViewController?

    public func logIn() {
        guard let presentingViewController else {
            assertionFailure("Set API.presentingViewController before calling logIn()")
            return
        }
        interactor.signIn(presenting: presentingViewController)
    }

    public func logOut() {
        interactor.signOut()
    }

    public func requestPermissions() {
        guard let presentingViewController else {
            assertionFailure("Set API.presentingViewController before calling requestPermissions()")
            return
        }
        interactor.addMissingScopes(presenting: presentingViewController)
    }

    public func restorePreviousSignIn() async {
        await interactor.restorePreviousSession(reportMissing: true)
    }

    @discardableResult
    public func refreshTokensIfNeeded() async throws -> UserSession {
        try await interactor.refreshTokensIfNeeded()
    }

    public func openUrl(_ url: URL) -> Bool {
        interactor.openUrl(url)
    }
}
