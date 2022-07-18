//  Error.swift
//  SwiftGoogleSignIn Package
//
//  Created by Serhii Krotkih on 6/14/22.
//

import Foundation

public enum SwiftError: Error {
    case message(String)
    case systemMessage(Int, String)

    func message() -> String {
        switch self {
        case .message(let message):
            return message
        case .systemMessage(let code, let message):
            return "System error: \(code)\n\(message)"
        }
    }

    func printDescription(_ comment: String? = nil,
                          _ file: String = #file,
                          _ function: String = #function,
                          _ line: Int = #line) {
        #if DEBUG
        print("💣 |E|\(function):\(line):[\(Thread.current)]\(comment ?? ""):\(self.message())")
        #endif
    }
}

enum SignInError: Error {
    case signInError(Error)
    case userIsUndefined
    case permissionsError
    case failedUserData

    func localizedString() -> String {
        switch self {
        case .signInError:
            return "The user has not signed in before or he has since signed out"
        case .userIsUndefined:
            return "The user has not signed in before or he has since signed out"
        case .permissionsError:
            return "Please add scopes to have ability to manage your YouTube videos. The app will not work properly"
        case .failedUserData:
            return "User data is wrong. Please try again later"
        }
    }
}
