//
//  PackageAPI.swift
//  SwiftGoogleSignIn Package
//
//  Created by Serhii Krotkykh on 6/14/22.
//

import UIKit
import Combine

public let API: SwiftGoogleSignInInterface = PackageAPI()

public protocol SwiftGoogleSignInInterface {
    func initialize(_ scopePermissions: [String]?)
    /// The Client has to handle openUrl
    /// The Client can subscribe on the Google user's connect state
    var publisher: AnyPublisher<UserSession, Never> { get }
    /// Just remember: we use SignInButton for the logging in Google account
    func logIn()
    /// Log out from the User's Google Account
    func logOut()
    /// As optional we can send request with scopes
    func requestPermissions()
    ///
    func openUrl(_ url: URL) -> Bool
    /// The Client has to set up UIViewController for Goggle SignIn UI base view
    var presentingViewController: UIViewController? { get set }
    /// The Client can subscribe on log out result
    var logoutResult: PassthroughSubject<Bool, Never>? { get }
}

// The Package Public Interface
public class PackageAPI: SwiftGoogleSignInInterface {
    private var interactor: GoogleInteractor?
    private var configurator: GoogleConfigurator?
    
    /// Scope permissions depends on your app functionality and must be accepted by the Google team
    public func initialize(_ scopePermissions: [String]?) {
        let localDataBase = LocalStorage()
        configurator = GoogleConfigurator(localStorage: localDataBase)
        interactor = GoogleInteractor(configurator: configurator!,
                                      scopePermissions: scopePermissions)
    }
    
    /// The Client has to handle openUrl
    public func openUrl(_ url: URL) -> Bool {
        return interactor?.openUrl(url) ?? false
    }
    
    /// The Client has to set up UIViewController for Goggle SignIn UI base view
    public var presentingViewController: UIViewController?
    
    /// Just remember: we use SignInButton for the logging in Google account
    public func logIn() {
        guard let viewController = presentingViewController else { fatalError("The presentingViewController has not been defined") }
        interactor?.signIn(with: viewController)
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
        guard let viewController = presentingViewController else { fatalError("The presentingViewController has not been defined") }
        interactor?.addPermissions(with: viewController)
    }
    
    /// The Client can subscribe on the Google user's connect state
    public var publisher: AnyPublisher<UserSession, Never> {
        if let interactor {
            return interactor.userSession.eraseToAnyPublisher()
        } else {
            fatalError("The package Google interactor should be defined")
        }
    }
}
