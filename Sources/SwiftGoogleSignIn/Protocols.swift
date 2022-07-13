//
//  Protocols.swift
//  SwiftGoogleSignIn
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
    func disconnect()
    func addPermissions()
}

public protocol SignInObservable {
    var userProfile: Published<UserProfile?>.Publisher { get }
    var userSession: Published<RemoteUserSession?>.Publisher { get }
    var loginResult: PassthroughSubject<Bool, SwiftError> { get }
    var logoutResult: PassthroughSubject<Bool, Never> { get }
}

// MARK: - Model's protocols

public protocol UserObservable: AnyObject {
    var userProfile: UserProfile? { get }
}
