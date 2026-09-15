import XCTest
@testable import SwiftGoogleSignIn

final class SwiftGoogleSignInTests: XCTestCase {
    func testEmptySessionIsNotConnected() {
        XCTAssertFalse(UserSession.empty.isConnected)
        XCTAssertNil(UserSession.empty.accessToken)
    }

    func testSessionWithProfileAndAuthIsConnected() {
        let session = UserSession(
            profile: UserProfile(userId: "42", email: "a@b.c"),
            remoteSession: UserAuthentication(userId: "42", idToken: "id", accessToken: "token")
        )
        XCTAssertTrue(session.isConnected)
        XCTAssertEqual(session.accessToken, "token")
    }

    func testAccessTokenExpiry() {
        let soon = UserAuthentication(userId: "1", idToken: "id", accessToken: "t",
                                      accessTokenExpirationDate: Date().addingTimeInterval(30))
        let later = UserAuthentication(userId: "1", idToken: "id", accessToken: "t",
                                       accessTokenExpirationDate: Date().addingTimeInterval(3600))
        let unknown = UserAuthentication(userId: "1", idToken: "id", accessToken: "t")
        XCTAssertTrue(soon.isAccessTokenExpiring())
        XCTAssertFalse(later.isAccessTokenExpiring())
        XCTAssertFalse(unknown.isAccessTokenExpiring())
    }

    func testMissingScopesDescriptionListsScopes() {
        let error = SignInError.missingScopes(["a", "b"])
        XCTAssertTrue(error.localizedDescription.contains("a, b"))
    }
}
