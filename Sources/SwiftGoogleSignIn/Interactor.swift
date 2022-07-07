//
//  Interactor.swift
//  SwiftGoogleSignIn
//
//  Created by Serhii Krotkykh
//

import Foundation
import GoogleSignIn
import GoogleSignInSwift
import Combine

class Interactor: NSObject, SignInInteractable, ObservableObject {
    // SignInObservable protocol
    let loginResult = PassthroughSubject<Bool, SwiftError>()
    let logoutResult = PassthroughSubject<Bool, Never>()
    var user: Published<GoogleUser?>.Publisher { $currentUser }
    
    // lifecycle
    init(configurator: SignInConfigurator,
         model: SignInModel,
         scopePermissions: [String]?) {
        self.configurator = configurator
        self.model = model
        self.scopePermissions = scopePermissions
        super.init()
        self.configure()
    }
    
    var presenter: UIViewController?
    
    // Private, Internal variable
    private var configurator: SignInConfigurator
    private var model: SignInModel
    private var scopePermissions: [String]?
    
    @Published private var currentUser: GoogleUser?
    
    private var cancellableBag = Set<AnyCancellable>()
    
    private func configure() {
        Task {
            await restorePreviousUser()
            suscribeOnUser()
        }
    }
    
    private func suscribeOnUser() {
        model
            .user
            .sink {
                print("SwiftSignIn: usr=\($0)")
                self.currentUser = $0
            }
            .store(in: &self.cancellableBag)
    }
    
    private func restorePreviousUser() async {
        do {
            if model.currentUser == nil {
                let previousUser = await asyncRestorePreviousUser()
                try model.createUserAccount(for: previousUser)
            }
        } catch SignInError.failedUserData {
            fatalError("Unexpected exception")
        } catch {
            fatalError("Unexpected exception")
        }
    }
    
    private func asyncRestorePreviousUser() async -> GIDGoogleUser {
        return await withCheckedContinuation { continuation in
            // source here: https://developers.google.com/identity/sign-in/ios/sign-in#3_attempt_to_restore_the_users_sign-in_state
            GIDSignIn.sharedInstance.restorePreviousSignIn { user, _ in
                guard let user = user else { return }
                continuation.resume(with: .success(user))
            }
        }
    }
}

// MARK: - SignInLaunched protocol implementstion

extension Interactor {
    // Retrieving user information
    func signIn() {
        guard let presenter = presenter else { return }
        // https://developers.google.com/identity/sign-in/ios/people#retrieving_user_information
        GIDSignIn.sharedInstance.signIn(with: configurator.signInConfig,
                                        presenting: presenter) { [weak self] user, error in
            guard let `self` = self else { return }
            self.handleSignInResult(user, error)
        }
    }
    
    func logOut() {
        GIDSignIn.sharedInstance.signOut()
        model.deleteLocalUserAccount()
        logoutResult.send(true)
    }
    
    // It is highly recommended that you provide users that signed in with Google the
    // ability to disconnect their Google account from your app. If the user deletes their account,
    // you must delete the information that your app obtained from the Google APIs.
    func disconnect() {
        GIDSignIn.sharedInstance.disconnect { error in
            guard error == nil else { return }
            // Google Account disconnected from your app.
            // Perform clean-up actions, such as deleting data associated with the
            //   disconnected account.
            self.logOut()
        }
    }

    func openUrl(_ url: URL) -> Bool {
        // The source looking for here: https://developers.google.com/identity/sign-in/ios/sign-in#ios_uiapplicationdelegate
        if GIDSignIn.sharedInstance.handle(url) {
            return true
        } else {
            // Handle other custom URL types.
            return false
        }
    }
}

// MARK: - Google Sign In Handler

extension Interactor {
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
    
    private func parseSignInResult(_ user: GIDGoogleUser?, _ error: Error?) throws {
        if let error = error {
            throw SignInError.signInError(error)
        } else if user == nil {
            throw SignInError.userIsUndefined
        } else if let user = user, checkPermissions(for: user) {
            do {
                try model.createUserAccount(for: user)
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

extension Interactor {
    private func checkPermissions(for user: GIDGoogleUser) -> Bool {
        guard let grantedScopes = user.grantedScopes else { return false }
        guard let scopePermissions = scopePermissions else { return true }
        let currentScopes = grantedScopes.compactMap { $0 }
        let havePermissions = currentScopes.contains(where: { scopePermissions.contains($0) })
        return havePermissions
    }
    
    func addPermissions() {
        guard let presenter = presenter else { return }
        guard let scopePermissions = scopePermissions else { return}
        // Your app should be verified already, so it does not make sense. I think so.
        GIDSignIn.sharedInstance.addScopes(scopePermissions,
                                           presenting: presenter,
                                           callback: { [weak self] user, error in
            self?.handleSignInResult(user, error)
        })
    }
}
