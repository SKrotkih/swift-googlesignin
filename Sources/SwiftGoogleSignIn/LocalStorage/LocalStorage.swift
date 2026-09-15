//
//  LocalStorage.swift
//  SwiftGoogleSignIn Package
//
//  Created by Serhii Krotkykh on 6/14/22.
//

import Foundation

protocol ConfigurableData {
    var clientID: String { get }
}

/// Reads the OAuth client id from the app bundle. Looked up in this order:
/// `CLIENT_ID` or `GIDClientID` in Info.plist, then `CLIENT_ID` in Config.plist.
struct LocalStorage: ConfigurableData {
    private let bundle: Bundle

    init(bundle: Bundle = .main) {
        self.bundle = bundle
    }

    var clientID: String {
        if let id = value(forKey: "CLIENT_ID", inPlist: "Info") { return id }
        if let id = value(forKey: "GIDClientID", inPlist: "Info") { return id }
        if let id = value(forKey: "CLIENT_ID", inPlist: "Config") { return id }
        fatalError("""
            SwiftGoogleSignIn: no Google OAuth client id found. Put it into Info.plist as CLIENT_ID \
            (or GIDClientID), or into Config.plist as CLIENT_ID in the main bundle.
            """)
    }

    private func value(forKey key: String, inPlist name: String) -> String? {
        guard let path = bundle.path(forResource: name, ofType: "plist"),
              let plist = NSDictionary(contentsOfFile: path),
              let id = plist[key] as? String,
              !id.isEmpty else { return nil }
        return id
    }
}
