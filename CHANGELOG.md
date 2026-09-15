# Changelog

## 2.0.0 — 2026-09-15

- Google Sign-In SDK **8.x** (`GIDSignIn.configuration`, `signIn(withPresenting:hint:additionalScopes:)`, async API, privacy manifest).
- Errors no longer terminate the session stream: `publisher` is `AnyPublisher<UserSession, Never>`, failures arrive on the new `errorPublisher` as typed `SignInError` values.
- New: `session` (current value), `refreshTokensIfNeeded()` for 401 handling, `restorePreviousSignIn()`.
- `requestPermissions()` asks only for the scopes not yet granted.
- `UserAuthentication` carries the token expiration date and the granted scopes; `accessToken` is non-optional.
- Client id can also be read from `GIDClientID` in Info.plist.
- Swift tools 5.9; the public interface is `@MainActor`.
- Removed: `SwiftError`, the unused UserDefaults storage.

## 1.60.0 — 2026-09-14

- Request the API scopes at sign-in (single consent screen); drop restored sessions that lack them.

## 1.58 — 2022-12-09

- `SwiftError` delivered through the session publisher.

## 1.56 — 2022-11-28, 1.43 — 2022-09-20

- Earlier releases on GoogleSignIn-iOS 6.x.
