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
    /// The Client has to set up UIViewController for Goggle SignIn UI base view
    var presentingViewController: UIViewController? { get set }
    /// Google user's connect state publisher
    var publisher: AnyPublisher<UserSession, SwiftError> { get }
    /// Please use SignInButton view for log in
    func logIn()
    /// Log out. Handle result via publisher
    func logOut()
    /// As optional we can send request with scopes
    func requestPermissions()
    /// The Client has to handle openUrl app delegate event
    func openUrl(_ url: URL) -> Bool
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
    
    /// The Client can subscribe on the Google user's connect state
    public var publisher: AnyPublisher<UserSession, SwiftError> {
        if let interactor {
            return interactor.userSession.eraseToAnyPublisher()
        } else {
            fatalError("Please use initialize before start of using the package")
        }
    }

    /// Handle openUrl app delegate event
    public func openUrl(_ url: URL) -> Bool {
        return interactor?.openUrl(url) ?? false
    }
    
    /// Define viewcontroller which is used for the Goggle SignIn base view
    public var presentingViewController: UIViewController?
    
    /// Log in Google account. Use SignInButton for that
    public func logIn() {
        guard let viewController = presentingViewController else { fatalError("Please send presentingViewController before") }
        interactor?.signIn(with: viewController)
    }
    
    /// Log out from the User's Google Account
    public func logOut() {
        interactor?.signOut()
    }

    /// As optional we can send request with scopes
    public func requestPermissions() {
        guard let viewController = presentingViewController else { fatalError("Please send presentingViewController before") }
        interactor?.addPermissions(with: viewController)
    }
}
