//
//  SignInAppDelegate.swift
//  LiveEvents
//
//  Created by Serhii Krotkykh on 6/13/22.
//

import UIKit
import GoogleSignIn

public class SignInAppDelegate: NSObject, UIApplicationDelegate {
    var scopePermissions: [String]?
    
    init(_ scopePermissions: [String]? = nil) {
        self.scopePermissions = scopePermissions
    }
    
    public func application(_ application: UIApplication,
                     didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        session.initialize(scopePermissions)
        return true
    }
    
    public func application(_ app: UIApplication,
                     open url: URL,
                     options: [UIApplication.OpenURLOptionsKey: Any] = [:]
    ) -> Bool {

        // The source looking for here: https://developers.google.com/identity/sign-in/ios/sign-in#ios_uiapplicationdelegate

        if GIDSignIn.sharedInstance.handle(url) {
            return true
        } else {
            // Handle other custom URL types.
            return false
        }
    }
}
