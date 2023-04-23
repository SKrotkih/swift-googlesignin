//
//  GoogleSignInService.swift
//  SwiftGoogleSignIn Package
//
//  Created by Serhii Krotkykh on 6/14/22.
//

import Foundation
import GoogleSignIn
import GoogleSignInSwift
import Combine

// MARK: - Google SignIn Service Protocol

typealias SignInServiceProtocol = SignInLaunchable & SignInObservable

protocol SignInLaunchable {
    func signIn(with viewController: UIViewController)
    func signOut()
    func addPermissions(with viewController: UIViewController)
}

protocol SignInObservable {
    var userSession: CurrentValueSubject<UserSession, SwiftError> { get }
}

// MARK: - Google Sign In Service Implementation

class GoogleSignInService: NSObject, ObservableObject {
    var userSession: CurrentValueSubject<UserSession, SwiftError> = CurrentValueSubject(UserSession.empty)
    
    // Private, Internal variable
    private var configurator: SignInConfigurator
    private var scopePermissions: [String]?
    
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

extension GoogleSignInService: SignInServiceProtocol {
    /// Signin in and get user accaunt data. Can be used SignInButton as well
    func signIn(with viewController: UIViewController) {
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
            switch error {
            case .some(let error):
                self.userSession.send(completion: .failure(SwiftError.message(error.localizedDescription)))
            case .none:
                // Google Account disconnected from your app.
                // Perform clean-up actions, such as deleting data associated with the
                //   disconnected account.
                self.userSession.send(UserSession.empty)
            }
        }
    }

    func openUrl(_ url: URL) -> Bool {
        // https://developers.google.com/identity/sign-in/ios/sign-in#ios_uiapplicationdelegate
        return GIDSignIn.sharedInstance.handle(url)
    }
}

// MARK: - Google Sign In Handler

extension GoogleSignInService {
    // [START signin_handler]
    private func handleSignInResult(_ user: GIDGoogleUser?, _ error: Error?) {
        do {
            try self.parseSignInResult(user, error)
        } catch SignInError.failedSignIn(let error) {
            if (error as NSError).code == GIDSignInError.hasNoAuthInKeychain.rawValue {
                let text = "401: \(SignInError.failedSignIn(error).localizedString())"
                userSession.send(completion: .failure(SwiftError.message(text)))
            } else {
                userSession.send(completion: .failure(SwiftError.message(error.localizedDescription)))
            }
        } catch SignInError.undefinedUser {
            let error = SwiftError.systemMessage(401, SignInError.undefinedUser.localizedString())
            userSession.send(completion: .failure(error))
        } catch SignInError.permissionsError {
            let error = SwiftError.systemMessage(501, SignInError.permissionsError.localizedString())
            userSession.send(completion: .failure(error))
        } catch SignInError.userDataError {
            userSession.send(completion: .failure( SwiftError.message(SignInError.userDataError.localizedString())))
        } catch {
            userSession.send(completion: .failure(SwiftError.message("Unexpected system error")))
        }
    }
    
    private func parseSignInResult(_ googleUser: GIDGoogleUser?, _ error: Error?) throws {
        switch (googleUser, error) {
        case (nil, .some(let error)):
            throw SignInError.failedSignIn(error)
        case (.some(let googleUser), nil):
            if checkPermissions(for: googleUser) {
                createNewUser(for: googleUser)
            } else {
                throw SignInError.permissionsError
            }
        case (nil, nil):
            throw SignInError.undefinedUser
        default:
            break
        }
    }
    // [END signin_handler]
}

// MARK: - Check and Add the Scope Permissions

extension GoogleSignInService {
    private func checkPermissions(for user: GIDGoogleUser) -> Bool {
        guard let grantedScopes = user.grantedScopes else { return false }
        guard let scopePermissions = scopePermissions else { return true }
        let currentScopes = grantedScopes.compactMap { $0 }
        let havePermissions = currentScopes.contains(where: { scopePermissions.contains($0) })
        return havePermissions
    }
    
    func addPermissions(with viewController: UIViewController) {
        guard let scopePermissions = scopePermissions else { return}
        // Your app should be verified already, so it does not make sense. I think so.
        GIDSignIn.sharedInstance.addScopes(scopePermissions,
                                           presenting: viewController,
                                           callback: { [weak self] user, error in
            self?.handleSignInResult(user, error)
        })
    }
}

// MARK: - Restore previous session

extension GoogleSignInService {
    func restorePreviousSession() async {
        let googleUser = await restorePreviousUser()
        createNewUser(for: googleUser)
    }
    
    private func restorePreviousUser() async -> GIDGoogleUser {
        return await withCheckedContinuation { continuation in
            // The source is here: https://developers.google.com/identity/sign-in/ios/sign-in#3_attempt_to_restore_the_users_sign-in_state
            GIDSignIn.sharedInstance.restorePreviousSignIn { user, _ in
                if let user { continuation.resume(with: .success(user)) }
            }
        }
    }
}

// MARK: - Create New User Session

extension GoogleSignInService {
    /**
        There is just two ways to create a new user: restore previous one and after log in
     */
    private func createNewUser(for googleUser: GIDGoogleUser) {
        if let profile = UserProfile(googleUser),
           let remoteSession = UserAuthentication(googleUser) {
            let userSession = UserSession(profile: profile, remoteSession: remoteSession)
            self.userSession.send(userSession)
        } else {
            userSession.send(completion: .failure( SwiftError.message(SignInError.userDataError.localizedDescription)))
        }
    }
}
