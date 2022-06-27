//  Configurator.swift
//  SwiftGoogleSignIn
//
//  Created by Serhii Krotkykh
//

import UIKit

public struct Configurator {
    
    public static func configureInteractor(with presenter: UIViewController) -> SignInInteractable {
        let interactor = Interactor(configurator: GoogleSignInConfigurator(),
                                    presenter: presenter,
                                    model: SignInModel())
        return interactor
    }
}
