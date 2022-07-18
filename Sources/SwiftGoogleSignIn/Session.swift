//
//  Session.swift
//  SwiftGoogleSignIn Package
//
//  Created by Serhii Krotkih on 6/14/22.
//

import UIKit
import Combine

public let session = Session()

public class Session {
    private var interactor: SignInInteractor?
    private var model: UserSessionStore?
    private var configurator: GoogleSignInConfigurator?
    
    public func initialize(_ scopePermissions: [String]?) {
        model = UserSessionStore()
        configurator = GoogleSignInConfigurator()
        interactor = SignInInteractor(configurator: configurator!,
                                model: model!,
                                scopePermissions: scopePermissions)
    }
    
    public func openUrl(_ url: URL) -> Bool {
        return interactor?.openUrl(url) ?? false
    }
     
    public var presentingViewController: UIViewController? {
        didSet {
            interactor?.presentingViewController = presentingViewController
        }
    }

    // The Client can use SignInButton too
    public func logIn() {
        interactor?.signIn()
    }
    
    public func logOut() {
        interactor?.logOut()
    }
    
    // As optional we can send request with scopes
    public func requestPermissions() {
        interactor?.addPermissions()
    }
    
    public func disconnect() {
        interactor?.disconnect()
    }
    
    // The Client can subscribe on log out result
    public var logoutResult: PassthroughSubject<Bool, Never>? {
        return interactor?.logoutResult
    }
    
    // The Client can subscribe on log in result
    public var loginResult: PassthroughSubject<Bool, SwiftError>? {
        return interactor?.loginResult
    }
    
    // The Client can subscribe on change of user profile as result of log in or log out
    public var userSession: Published<UserSession?>.Publisher? {
        return interactor?.userSession
    }

    // The Client uses it as Google API token
    public var oauthAccessToken: String? {
        return model?.userSession?.remoteSession.accessToken
    }
    
    // Current user profile parameters: user's full name
    public var userFullName: String? {
        return model?.userSession?.profile.fullName
    }
    
    // Current user profile parameters: user's avatar url
    public var userProfilePictureUrl: URL? {
        return model?.userSession?.profile.profilePicUrl
    }
}
