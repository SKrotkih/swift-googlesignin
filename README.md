<p align="center">
  <a href="https://github.com/SKrotkih/swift-googlesignin/actions/workflows/ci.yml"><img src="https://github.com/SKrotkih/swift-googlesignin/actions/workflows/ci.yml/badge.svg"/></a>
  <img src="https://img.shields.io/badge/swift-5.9-orange"/>
  <img src="https://img.shields.io/badge/iOS-15%2B-blue"/>
  <img src="https://img.shields.io/badge/License-MIT-yellow"/>
</p>

# SwiftGoogleSignIn 2.0

A thin Combine wrapper around [Google Sign-In for iOS](https://github.com/google/GoogleSignIn-iOS) (SDK 8):
one entry point (`API`), a session publisher, an error publisher, and a `SignInButton` for SwiftUI.
It requests your Google API scopes on the sign-in consent screen and hands you the access token.

Used by the [LiveEvents](https://github.com/SKrotkih/LiveEvents) sample app together with
[YTLiveStreaming](https://github.com/SKrotkih/YTLiveStreaming).

## Requirements

iOS 15+, Swift 5.9 / Xcode 15+, GoogleSignIn-iOS 8.x (pulled in automatically).

## Installation

Xcode → **File ▸ Add Package Dependencies…** → `https://github.com/SKrotkih/swift-googlesignin.git`, **Up to Next Major** from `2.0.0`.

Or in `Package.swift`:

```swift
.package(url: "https://github.com/SKrotkih/swift-googlesignin.git", from: "2.0.0")
```

## Setup

1. Create an **iOS OAuth client ID** in [Google Cloud Console](https://console.cloud.google.com/apis/credentials) with your bundle id.
2. Put the client id into your app as `CLIENT_ID` (or `GIDClientID`) in `Info.plist`, or as `CLIENT_ID` in a `Config.plist` in the main bundle.
3. Add the **reversed client id** (`com.googleusercontent.apps.…`) to **URL Types** in your target.
4. While the OAuth consent screen is in *Testing* mode, add your Google account as a test user.

## Usage

Initialise once at start-up with the scopes your app needs (`nil` for plain sign-in), and forward the open-URL callback:

```swift
import SwiftGoogleSignIn

let youtubeScopes = [
    "https://www.googleapis.com/auth/youtube",
    "https://www.googleapis.com/auth/youtube.readonly",
    "https://www.googleapis.com/auth/youtube.force-ssl"
]

// AppDelegate / App
API.initialize(youtubeScopes)

func application(_ app: UIApplication, open url: URL, options: [UIApplication.OpenURLOptionsKey: Any] = [:]) -> Bool {
    API.openUrl(url)
}
// or in SwiftUI: .onOpenURL { _ = API.openUrl($0) }
```

Put the button on your log-in screen and tell the package which view controller to present from:

```swift
API.presentingViewController = window.rootViewController

struct LogInView: View {
    var body: some View {
        SignInButton()   // calls API.logIn()
    }
}
```

Subscribe to the session and to errors — two separate, never-failing streams:

```swift
API.publisher
    .receive(on: RunLoop.main)
    .sink { session in
        if session.isConnected {
            // session.profile, session.remoteSession?.accessToken
        } else {
            // signed out
        }
    }
    .store(in: &cancellables)

API.errorPublisher
    .receive(on: RunLoop.main)
    .sink { error in
        switch error {
        case .cancelled:            break                     // user dismissed the sheet
        case .missingScopes:        API.requestPermissions()  // ask again
        default:                    show(error.localizedDescription)
        }
    }
    .store(in: &cancellables)
```

The previous sign-in is restored from the Keychain automatically when the package is first used;
a restored session that lacks the required scopes is dropped so the user sees the sign-in screen again.

### Token refresh

Google access tokens live about an hour. When an API call answers **401**, refresh and retry:

```swift
let session = try await API.refreshTokensIfNeeded()
let token = session.remoteSession?.accessToken
```

With YTLiveStreaming this is the natural `TokenProvider` implementation:

```swift
struct GoogleTokenProvider: TokenProvider {
    func accessToken() async throws -> String {
        guard let token = await API.session.accessToken else { throw YouTubeLiveError.missingAccessToken }
        return token
    }
    func refreshAccessToken() async throws -> String? {
        try await API.refreshTokensIfNeeded().accessToken
    }
}
```

## Interface

```swift
@MainActor public protocol SwiftGoogleSignInInterface: AnyObject {
    func initialize(_ scopePermissions: [String]?)
    var publisher: AnyPublisher<UserSession, Never> { get }
    var errorPublisher: AnyPublisher<SignInError, Never> { get }
    var session: UserSession { get }
    var presentingViewController: UIViewController? { get set }
    func logIn()
    func logOut()
    func requestPermissions()
    func restorePreviousSignIn() async
    @discardableResult func refreshTokensIfNeeded() async throws -> UserSession
    func openUrl(_ url: URL) -> Bool
}
```

`UserSession` holds a `UserProfile` (id, names, email, picture) and a `UserAuthentication`
(id token, access token, its expiration date, granted scopes). `SignInError` cases:
`cancelled`, `noPreviousSignIn`, `missingScopes([String])`, `invalidUserData`, `refreshFailed`, `signOutFailed`, `sdk`.

## Migrating from 1.x

| 1.x | 2.0 |
|---|---|
| `publisher: AnyPublisher<UserSession, SwiftError>`; an error **completed** the stream | `publisher: AnyPublisher<UserSession, Never>` + `errorPublisher: AnyPublisher<SignInError, Never>` |
| `SwiftError.message` / `.systemMessage(401/501, …)` | typed `SignInError` (`LocalizedError`) |
| — | `session`, `refreshTokensIfNeeded()`, `restorePreviousSignIn()` |
| `UserAuthentication.accessToken: String?` | `String` (non-optional) + `accessTokenExpirationDate`, `grantedScopes` |
| GoogleSignIn-iOS 6.x | 8.x (privacy manifest included by the SDK) |
| Swift 5.7 | Swift 5.9; `API` and the interface are `@MainActor` |

## History

See [CHANGELOG.md](CHANGELOG.md).

## License

MIT
