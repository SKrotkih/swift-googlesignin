//
//  LocalStorage.swift
//  SwiftGoogleSignIn Package
//
//  Created by Serhii Krotkykh on 6/14/22.
//

import Foundation

protocol DataPreservable {
    func saveObject<T: Encodable>(_ object: T, key: String) throws
    func restoreObject<T: Decodable>(key: String) -> T?
    func removeObject(key: String)
}

protocol ConfigurableData {
    var clientID: String { get }
}

/// Serialize objects to the userdefaults storage. we used to use it for UserSession but it does not make sence on my opinion
struct LocalStorage: DataPreservable {
    func saveObject<T: Encodable>(_ object: T, key: String) throws {
        if let data = try? JSONEncoder().encode(object) {
            let userDefaults = UserDefaults.standard
            userDefaults.set(data, forKey: key)
            userDefaults.synchronize()
        } else {
            throw SwiftError.message("Encode '\(key)' error")
        }
    }

    func restoreObject<T: Decodable>(key: String) -> T? {
        var savedObject: T?
        if let data = UserDefaults.standard.object(forKey: key) as? Data {
            let decoder = JSONDecoder()
            if let object = try? decoder.decode(T.self, from: data) {
                savedObject = object
            }
        }
        return savedObject
    }

    func removeObject(key: String) {
        UserDefaults.standard.removeObject(forKey: key)
    }
}

// MARK: - Preserved in a plist file configurable Data 

extension LocalStorage: ConfigurableData {
    private func getPlist(_ name: String) -> NSDictionary? {
        if let path = Bundle.main.path(forResource: name, ofType: "plist") {
            return NSDictionary(contentsOfFile: path) as NSDictionary?
        } else {
            return nil
        }
    }

    /**
    Get user's Client ID from config plist file in the main bundle
     */
    var clientID: String {
        let key = "CLIENT_ID"
        if let plist = getPlist("Info"), let id = plist[key] as? String, !id.isEmpty {
            return id
        } else if let plist = getPlist("Config"), let id = plist[key] as? String, !id.isEmpty {
            return id
        } else {
            assert(false, "Please put your Client ID into info.plist file in the main bundle as a GoogleAPIClientID value")
        }
    }
}
