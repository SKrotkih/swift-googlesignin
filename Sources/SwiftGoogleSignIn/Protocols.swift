//
//  Protocols.swift
//  LiveEvents
//
//  Created by Serhii Krotkykh on 10/31/20.
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
    var user: Published<GoogleUser?>.Publisher { get }
    var loginResult: PassthroughSubject<Bool, SwiftError> { get }
    var logoutResult: PassthroughSubject<Bool, Never> { get }
}

// MARK: - Model's protocols

public protocol UserObservable: AnyObject {
    var user: GoogleUser? { get }
}
