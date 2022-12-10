//  Error.swift
//  SwiftGoogleSignIn Package
//
//  Created by Serhii Krotkykh on 6/14/22.
//

import Foundation

/**
 Create Error Message
 
 - Enum Cases:
    - .message(String) : ordinary message
    - .systemMessage(Int, String) : message with return code
    - func message() -> String : get full formatted text message
 
   # Example:
            throw SwiftError.message("Encode  error")
 */
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
    case failedSignIn(Error)
    case undefinedUser
    case permissionsError
    case userDataError
    case message(String)

    func localizedString() -> String {
        switch self {
        case .failedSignIn:
            return "The user has not signed in before or he has since signed out"
        case .undefinedUser:
            return "The user has not signed in before or he has since signed out"
        case .permissionsError:
            return "Please add scopes to have ability to manage your YouTube videos. The app will not work properly"
        case .userDataError:
            return "User data is wrong. Please try again later"
        case .message(let text):
            return text
        }
    }
}
