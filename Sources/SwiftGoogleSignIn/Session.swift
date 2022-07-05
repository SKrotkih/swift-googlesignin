//
//  File.swift
//  
//
//  Created by Sergey Krotkih on 6/28/22.
//

import UIKit
import Combine

public let session = Session()

public class Session {
    private var interactor: Interactor?
    
    public func initialize(_ scopePermissions: [String]?) {
        interactor = Interactor(configurator: GoogleSignInConfigurator(),
                                model: SignInModel(),
                                scopePermissions: scopePermissions)
    }
    
    public func openUrl(_ url: URL) -> Bool {
        return interactor?.openUrl(url) ?? false
    }
    
    public func addDependency(on presenter: UIViewController) {
        interactor?.presenter = presenter
    }
    
    func logIn() {
        interactor?.signIn()
    }
    
    public func logOut() {
        interactor?.logOut()
    }
    
    public func requestPermissions() {
        interactor?.addPermissions()
    }
    
    public func disconnect() {
        interactor?.disconnect()
    }
    
    public var logoutResult: PassthroughSubject<Bool, Never>? {
        return interactor?.logoutResult
    }
    
    public var loginResult: PassthroughSubject<Bool, SwiftError>? {
        return interactor?.loginResult
    }
    
    public var user: Published<GoogleUser?>.Publisher? {
        return interactor?.user
    }
}
