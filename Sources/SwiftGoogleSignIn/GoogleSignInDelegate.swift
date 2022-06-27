//
//  GoogleSignInDelegate.swift
//  LiveEvents
//
//  Created by Serhii Krotkykh on 6/13/22.
//

import UIKit
import GoogleSignIn

public class GoogleSignInDelegate: NSObject, UIApplicationDelegate {
    public func application(_ app: UIApplication,
                     open url: URL,
                     options: [UIApplication.OpenURLOptionsKey: Any] = [:]
    ) -> Bool {

        // source from https://developers.google.com/identity/sign-in/ios/sign-in#ios_uiapplicationdelegate

        if GIDSignIn.sharedInstance.handle(url) {
            return true
        } else {
            // Handle other custom URL types.
            return false
        }
    }
}
