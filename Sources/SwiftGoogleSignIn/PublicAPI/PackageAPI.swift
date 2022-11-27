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
    private var configurator: GoogleConfigurator?
    
    /// Scope permissions depends on your app functionality and must be accepted by the Google team
    public func initialize(_ scopePermissions: [String]?) {
        let localDataBase = LocalStorage()
        configurator = GoogleConfigurator(localStorage: localDataBase)
        interactor = GoogleInteractor(configurator: configurator!,
                                      localDataBase: localDataBase,
                                      scopePermissions: scopePermissions)
    }
    
    /// The Client has to handle openUrl
    public func openUrl(_ url: URL) -> Bool {
        return interactor?.openUrl(url) ?? false
    }
    
    /// The Client has to set up UIViewController for Goggle SignIn UI base view
    public var presentingViewController: UIViewController? {
        didSet {
            interactor?.presentingViewController = presentingViewController
        }
    }
    
    /// Just remember: we use SignInButton for the logging in Google account
    public func logIn() {
        interactor?.signIn()
    }
    
    /// The Client can subscribe on log in result
    public var loginResult: PassthroughSubject<Bool, SwiftError>? {
        return interactor?.loginResult
    }
    
    /// Log out from the User's Google Account
    public func logOut() {
        interactor?.signOut()
    }
    
    /// The Client can subscribe on log out result
    public var logoutResult: PassthroughSubject<Bool, Never>? {
        return interactor?.logoutResult
    }
    
    /// As optional we can send request with scopes
    public func requestPermissions() {
        interactor?.addPermissions()
    }
    
    /// The Client can subscribe on the Google user's connect state
    public var currentUser: CurrentValueSubject<UserSession?, Never> {
        if let interactor {
            return interactor.userSession
        } else {
            return CurrentValueSubject(nil)
        }
    }
}
