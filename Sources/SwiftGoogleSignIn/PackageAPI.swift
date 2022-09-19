//
//  PackageAPI.swift
//  SwiftGoogleSignIn Package
//
//  Created by Serhii Krotkih on 6/14/22.
//

import UIKit
import Combine

public let packageAPI = PackageAPI()

// The Package Public Interface
public class PackageAPI {
    private var interactor: GoogleInteractor?
    private var sessionStarage: SessionStorage?
    private var configurator: GoogleConfigurator?
    
    public func initialize(_ scopePermissions: [String]?) {
        sessionStarage = SessionStorage()
        configurator = GoogleConfigurator()
        interactor = GoogleInteractor(configurator: configurator!,
                                      sessionStarage: sessionStarage!,
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
    public var userSessionObservable: Published<UserSession?>.Publisher? {
        return interactor?.userSessionObservable
    }
    
    public var userSession: UserSession? {
        return interactor?.userSession
    }
}
