//
//  GoogleInteractor.swift
//  SwiftGoogleSignIn Package
//
//  Created by Serhii Krotkih on 6/14/22.
//

import Foundation
import GoogleSignIn
import GoogleSignInSwift
import Combine

// MARK: - SignIn Interactor Protocol

typealias SignInInteractable = SignInLaunchable & SignInObservable

protocol SignInLaunchable {
    func signIn()
    func signOut()
    func addPermissions()
}

protocol SignInObservable {
    var userSession: CurrentValueSubject<UserSession?, Never> { get }
    var loginResult: PassthroughSubject<Bool, SwiftError> { get }
    var logoutResult: PassthroughSubject<Bool, Never> { get }
}

// MARK: - SignIn Interactor

class GoogleInteractor: NSObject, ObservableObject {
    let loginResult = PassthroughSubject<Bool, SwiftError>()
    let logoutResult = PassthroughSubject<Bool, Never>()
    
    @Published private var currentUserSession: UserSession?

    var userSession: CurrentValueSubject<UserSession?, Never> = CurrentValueSubject(nil)
    
    var presentingViewController: UIViewController?
    
    // Private, Internal variable

    private var configurator: SignInConfigurator
    private var scopePermissions: [String]?
    
    private var cancellableBag = Set<AnyCancellable>()

    private let userSessionKey = UserSession.keyName
    
    // lifecycle
    init(configurator: SignInConfigurator,
         scopePermissions: [String]?) {
        self.configurator = configurator
        self.scopePermissions = scopePermissions
        super.init()
        Task {
            await restorePreviousSession()
        }
    }
}

// MARK: - SignInLaunchable protocol implementstion

extension GoogleInteractor: SignInInteractable {
    // Retrieving user information. The Client can use SignInButton too.
    func signIn() {
        guard let viewController = presentingViewController else { return }
        // https://developers.google.com/identity/sign-in/ios/people#retrieving_user_information
        GIDSignIn.sharedInstance.signIn(with: configurator.signInConfig,
                                        presenting: viewController) { [weak self] user, error in
            guard let `self` = self else { return }
            self.handleSignInResult(user, error)
        }
    }
    
    func signOut() {
        GIDSignIn.sharedInstance.signOut()
        // It is highly recommended that you provide users that signed in with Google the
        // ability to disconnect their Google account from your app. If the user deletes their account,
        // you must delete the information that your app obtained from the Google APIs.
        GIDSignIn.sharedInstance.disconnect { error in
            guard error == nil else { return }
            // Google Account disconnected from your app.
            // Perform clean-up actions, such as deleting data associated with the
            //   disconnected account.
            self.userSession.send(nil)
            self.logoutResult.send(true)
        }
    }

    func openUrl(_ url: URL) -> Bool {
        // The source looking for here: https://developers.google.com/identity/sign-in/ios/sign-in#ios_uiapplicationdelegate
        if GIDSignIn.sharedInstance.handle(url) {
            return true
        } else {
            return false
        }
    }
}

// MARK: - Google Sign In Handler

extension GoogleInteractor {
    private func handleSignInResult(_ user: GIDGoogleUser?, _ error: Error?) {
        do {
            try self.parseSignInResult(user, error)
            self.loginResult.send(true)
        } catch SignInError.signInError(let error) {
            if (error as NSError).code == GIDSignInError.hasNoAuthInKeychain.rawValue {
                self.loginResult.send(completion: .failure(.systemMessage(401, SignInError.signInError(error).localizedString())))
            } else {
                self.loginResult.send(completion: .failure(.message(error.localizedDescription)))
            }
        } catch SignInError.userIsUndefined {
            self.loginResult.send(completion: .failure(.systemMessage(401, SignInError.userIsUndefined.localizedString())))
        } catch SignInError.permissionsError {
            self.loginResult.send(completion: .failure(.systemMessage(501, SignInError.permissionsError.localizedString())))
        } catch SignInError.failedUserData {
            self.loginResult.send(completion: .failure(.message(SignInError.failedUserData.localizedString())))
        } catch {
            fatalError("Unexpected exception")
        }
    }
    
    private func parseSignInResult(_ googleUser: GIDGoogleUser?, _ error: Error?) throws {
        if let error {
            throw SignInError.signInError(error)
        } else if googleUser == nil {
            throw SignInError.userIsUndefined
        } else if let googleUser, checkPermissions(for: googleUser) {
            do {
                try createNewUser(for: googleUser)
            } catch SignInError.failedUserData {
                throw SignInError.failedUserData
            } catch {
                fatalError("Unexpected exception")
            }
        } else {
            throw SignInError.permissionsError
        }
    }
    // [END signin_handler]
}

// MARK: - Check/Add the Scopes

extension GoogleInteractor {
    private func checkPermissions(for user: GIDGoogleUser) -> Bool {
        guard let grantedScopes = user.grantedScopes else { return false }
        guard let scopePermissions = scopePermissions else { return true }
        let currentScopes = grantedScopes.compactMap { $0 }
        let havePermissions = currentScopes.contains(where: { scopePermissions.contains($0) })
        return havePermissions
    }
    
    func addPermissions() {
        guard let presenter = presentingViewController else { return }
        guard let scopePermissions = scopePermissions else { return}
        // Your app should be verified already, so it does not make sense. I think so.
        GIDSignIn.sharedInstance.addScopes(scopePermissions,
                                           presenting: presenter,
                                           callback: { [weak self] user, error in
            self?.handleSignInResult(user, error)
        })
    }
}

// MARK: - Restore previous session

extension GoogleInteractor {
    func restorePreviousSession() async {
        do {
            let googleUser = await requestPreviousUser()
            try createNewUser(for: googleUser)
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
                if let user { continuation.resume(with: .success(user)) }
            }
        }
    }
}

extension GoogleInteractor {
    private func createNewUser(for googleUser: GIDGoogleUser) throws {
        do {
            let profile = UserProfile(googleUser)
            let remoteSession = UserAuthentication(googleUser)
            if profile == nil || remoteSession == nil {
                throw SignInError.failedUserData
            }
            let userSession = UserSession(profile: profile!, remoteSession: remoteSession!)
            self.userSession.send(userSession)
        } catch SwiftError.message(let error) {
            fatalError("\(error): Unexpected exception")
        } catch {
            self.userSession.send(nil)
            throw SignInError.failedUserData
        }
    }
}
