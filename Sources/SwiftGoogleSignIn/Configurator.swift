//  Configurator.swift
//  SwiftGoogleSignIn
//
//  Created by Serhii Krotkykh
//

import UIKit

public struct Configurator {
    
    public static func createSignInInteractor(_ viewController: UIViewController) -> SignInInteractable {
        var interactor: SignInInteractable = Interactor()
        interactor.configurator = GoogleSignInConfigurator()
        interactor.presenter = viewController
        interactor.model = SignInModel()
        interactor.configure()
        return interactor
    }

    
}
