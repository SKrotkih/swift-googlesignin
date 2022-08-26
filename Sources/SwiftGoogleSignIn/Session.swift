//
//  Session.swift
//  SwiftGoogleSignIn Package
//
//  Created by Serhii Krotkih on 6/14/22.
//

import UIKit
import Combine

public let session = GoogleSignInSession()

// The Package Public Interface
public class GoogleSignInSession {
    private var interactor: GoogleInteractor?
    private var model: UserSessionStore?
    private var configurator: GoogleConfigurator?
    
    public func initialize(_ scopePermissions: [String]?) {
        model = UserSessionStore()
        configurator = GoogleConfigurator()
        interactor = GoogleInteractor(configurator: configurator!,
                                model: model!,
                                scopePermissions: scopePermissions)
    }
    
    // The Client has to handle openUrl
    public func openUrl(_ url: URL) -> Bool {
        return interactor?.openUrl(url) ?? false
    }
     
    // The Client has to set up UIViewController for Goggle SignIn UI base view
    public var presentingViewController: UIViewController? {
        didSet {
            interactor?.presentingViewController = presentingViewController
        }
    }

    // The Client can use SignInButton too.
    public func logIn() {
        interactor?.signIn()
    }
    
    // The Client can subscribe on log in result
    public var loginResult: PassthroughSubject<Bool, SwiftError>? {
        return interactor?.loginResult
    }

    public func logOut() {
        interactor?.logOut()
    }

    // The Client can subscribe on log out result
    public var logoutResult: PassthroughSubject<Bool, Never>? {
        return interactor?.logoutResult
    }

    // As optional we can send request with scopes
    public func requestPermissions() {
        interactor?.addPermissions()
    }
    
    // The Client can subscribe on UserSession to have access to user profile and Google API tokens
    public var userSessionObservanle: Published<UserSession?>.Publisher? {
        return interactor?.userSessionObservanle
    }
    
    public var userSession: UserSession? {
        return interactor?.userSession
    }
}
