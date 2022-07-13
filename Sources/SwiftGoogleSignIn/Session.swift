//
//  Session.swift
//  SwiftGoogleSignIn
//
//  Created by Serhii Krotkih on 6/14/22.
//

import UIKit
import Combine

public let session = Session()

public class Session {
    private var interactor: SignInInteractor?
    private var model: SignInModel?
    private var configurator: GoogleSignInConfigurator?
    
    public func initialize(_ scopePermissions: [String]?) {
        model = SignInModel()
        configurator = GoogleSignInConfigurator()
        interactor = SignInInteractor(configurator: configurator!,
                                model: model!,
                                scopePermissions: scopePermissions)
    }
    
    public func openUrl(_ url: URL) -> Bool {
        return interactor?.openUrl(url) ?? false
    }
    
    public func addDependency(on presentingViewController: UIViewController) {
        interactor?.presentingViewController = presentingViewController
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
    
    public var userProfile: Published<UserProfile?>.Publisher? {
        return interactor?.userProfile
    }

    public var oauthAccessToken: String? {
        return model?.remoteUserSession?.accessToken
    }
    
    public var userFullName: String? {
        return model?.userProfile?.fullName
    }
    
    public var userProfilePictureUrl: URL? {
        return model?.userProfile?.profilePicUrl
    }
}
