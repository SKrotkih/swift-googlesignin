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
    /// Init method with Google API scope permissions
    func initialize(_ scopePermissions: [String]?)
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
    /// The Client has to set up UIViewController for Goggle SignIn UI base view
    var presentingViewController: UIViewController? { get set }
}

// The Package Public Interface
public class PackageAPI: SwiftGoogleSignInInterface {
    private var scopePermissions: [String]?
    
    /// Scope permissions (SP) depend on your app functionality: some API requests requare accepted permissions. Keep it in mind.
    /// If you don't provide the SP the package tries to send API request by force.
    ///
    public func initialize(_ scopePermissions: [String]?) {
        self.scopePermissions = scopePermissions
    }

    lazy private var configurator: GoogleConfigurator = {
        let localDataBase = LocalStorage()
        return GoogleConfigurator(localStorage: localDataBase)
    }()

    lazy private var interactor: GoogleSignInService = {
        return GoogleSignInService(configurator: configurator,
                                scopePermissions: scopePermissions)
    }()

    /// The Client can subscribe on the Google user's connect state
    public var publisher: AnyPublisher<UserSession, SwiftError> {
        return interactor.userSession.eraseToAnyPublisher()
    }

    /// Handle openUrl app delegate event
    public func openUrl(_ url: URL) -> Bool {
        return interactor.openUrl(url)
    }
    
    /// Provide viewcontroller used for Goggle SignIn base view
    public var presentingViewController: UIViewController?
    
    /// Log in Google account. Use SignInButton for that
    public func logIn() {
        if presentingViewController == nil {
            assertionFailure("Please send presentingViewController before")
        }
        interactor.signIn(with: presentingViewController!)
    }
    
    /// Log out from the User's Google Account
    public func logOut() {
        interactor.signOut()
    }

    /// As optional we can send request with scopes
    public func requestPermissions() {
        if presentingViewController == nil {
            assertionFailure("Please send presentingViewController before")
        }
        interactor.addPermissions(with: presentingViewController!)
    }
}
