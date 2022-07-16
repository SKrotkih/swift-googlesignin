//
//  LocalStorage.swift
//  SwiftGoogleSignIn
//
//  Created by Serhii Krotkih on 6/14/22.
//

import Foundation

struct LocalStorage {
    static func saveObject<T: Encodable>(_ object: T, key: String) throws {
        if let data = try? JSONEncoder().encode(object) {
            let userDefaults = UserDefaults.standard
            userDefaults.set(data, forKey: key)
            userDefaults.synchronize()
        } else {
            throw SwiftError.message("Encode '\(key)' error")
        }
    }

    static func restoreObject<T: Decodable>(key: String) -> T? {
        var savedObject: T?
        if let data = UserDefaults.standard.object(forKey: key) as? Data {
            let decoder = JSONDecoder()
            if let object = try? decoder.decode(T.self, from: data) {
                savedObject = object
            }
        }
        return savedObject
    }

    static func removeObject(key: String) {
        UserDefaults.standard.removeObject(forKey: key)
    }
    
    static func getPlist(_ name: String) -> NSDictionary? {
        if let path = Bundle.main.path(forResource: name, ofType: "plist") {
            return NSDictionary(contentsOfFile: path) as NSDictionary?
        } else {
            return nil
        }
    }
}
