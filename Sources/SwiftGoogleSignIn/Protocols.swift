//
//  Protocols.swift
//  SwiftGoogleSignIn Package
//
//  Created by Serhii Krotkih on 6/14/22.
//

import Foundation
import Combine
import GoogleSignIn

// MARK: - SignIn Interactor Protocol

public typealias SignInInteractable = SignInLaunched & SignInObservable

public protocol SignInLaunched {
    func signIn()
    func logOut()
    func addPermissions()
}

public protocol SignInObservable {
    var userSessionObservable: Published<UserSession?>.Publisher { get }
    var loginResult: PassthroughSubject<Bool, SwiftError> { get }
    var logoutResult: PassthroughSubject<Bool, Never> { get }
}

// MARK: - Model's protocols

public protocol UserSessionObservable: AnyObject {
    var userSession: UserSession? { get }
}
