//
//  SignInProtocols.swift
//  LiveEvents
//
//  Created by Serhii Krotkykh on 10/31/20.
//  Copyright © 2020 Serhii Krotkykh. All rights reserved.
//

import Foundation
import Combine
import GoogleSignIn


// MARK: - SignIn Interactor Protocol

typealias SignInInteractable = SignInObservable & SignInConfiguarble & SignInLaunched

protocol SignInConfiguarble {
    var configurator: SignInConfigurator { get set }
    var presenter: UIViewController { get set }
    var model: SignInModel { get set }
    func configure()
}

protocol SignInObservable {
    var userPublisher: Published<GoogleUser?>.Publisher { get }
    var signInResultPublisher: PassthroughSubject<Bool, LocalError> { get }
    var logOutPublisher: PassthroughSubject<Bool, Never> { get }
}

protocol SignInLaunched {
    func signIn()
    func logOut()
    func disconnect()
    func addPermissions()
}

// MARK: - Model's protocols

typealias SignInStorage = SighInDelegate & UserProfile & Authenticatable & UserObservable

protocol SighInDelegate: AnyObject {
    func createLocalUserAccount(for user: GIDGoogleUser) throws
    func deleteLocalUserAccount()
}

protocol UserProfile {
    var userName: String { get }
    var userInfo: String { get }
    var avatarURL: URL? { get }
}

protocol Authenticatable {
    var authIdToken: String? { get }
    var authAccessToken: String? { get }
}

protocol UserObservable: AnyObject {
    var user: GoogleUser? { get }
}
