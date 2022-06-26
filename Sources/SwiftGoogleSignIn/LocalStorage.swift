//
//  LocalStorage.swift
//  LiveEvents
//

import Foundation

struct LocalStorage {
    static func saveObject<T: Encodable>(_ object: T, key: String) throws {
        if let data = try? JSONEncoder().encode(object) {
            let userDefaults = UserDefaults.standard
            userDefaults.set(data, forKey: key)
            userDefaults.synchronize()
        } else {
            throw LVError.message("Encode '\(key)' error")
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
}
