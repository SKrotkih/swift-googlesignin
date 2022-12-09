<p align="center">
  <img src="https://img.shields.io/badge/swift-5.7-orange"/>
  <img src="https://img.shields.io/badge/License-MIT-yellow"/>
</p>

# SwiftGoogleSignIn v1.58

SwiftGoogleSignIn is an open-source package which uses [Google Sign-In for iOS and macOS](https://developers.google.com/identity/sign-in/ios/start) and can be used to make sign in.
[Here](https://github.com/SKrotkih/LiveEvents) you can find an example of using this package.

## Requirements
iOS 15, Swift 5.7

## How to install it:

- open your Xcode project for iOS
- select **File**-**Add packages...**
- in the Apple Swift Packages screen select **Search or Enter Package URL**
- enter https://github.com/SKrotkih/swift-googlesignin.git
- make sure **SwiftGoogleSignIn** is opened
- press **Add Package** 
- Xcode creates 'Package Pependencies' group with SwiftGoogleSignIn package with last version 
- open your Xcode project settings - PROJECT section on the Package Dependencies tab
- make sure the SwiftGoogleSignIn package name is presented there 

## How to use the package:

- initialize stage:

```
   import SwiftGoogleSignIn
```

First of all you need approved scope permission. There are sensitive scopes for Google APIs to have ability to work properly
Make sure they are presented in your app. Then send request on verification. After the verification provide them for the
initializa method:

```
   let googleAPIscopes: [String] = ["https://www.googleapis.com/auth/youtube",
       "https://www.googleapis.com/auth/youtube.readonly",
       "https://www.googleapis.com/auth/youtube.force-ssl"]

   func application(_ application: UIApplication,
                    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
      SwiftGoogleSignIn.API.initialize(googleAPIscopes) 
   }
```
 Handle open URL: 
   
```
   func application(_ application: UIApplication,
                    open url: URL,
                    options: [UIApplication.OpenURLOptionsKey: Any] = [:]
   ) -> Bool {
       return SwiftGoogleSignIn.API.openUrl(url)
   }
```
 
- put 'Sign In' button on your Log in screen:

```
   import SwiftGoogleSignIn

   struct LogInContentView: View {

      var body: some View {
         ...
         SignInButton()
         ...
      }
   }
```
- subscribe on the User sign in result action:
```
   SwiftGoogleSignIn.API
      .publisher
      .receive(on: RunLoop.main)
      .sink { session in
         // session is a UserSession structure data
      }
```      

## Interface:

```
    func initialize(_ scopePermissions: [String]?)
    /// The Client has to set up UIViewController for Goggle SignIn UI base view
    var presentingViewController: UIViewController? { get set }
    /// Google user's connect state publisher
    var publisher: AnyPublisher<UserSession, SwiftError> { get }
    /// Please use SignInButton view for log in
    func logIn()
    /// Log out. Handle result via publisher
    func logOut()
    /// As optional we can send request with scopes
    func requestPermissions()
    /// The Client has to handle openUrl app delegate event
    func openUrl(_ url: URL) -> Bool
```

[Example of using the package](https://github.com/SKrotkih/LiveEvents)

## History

- 09-12-2022. 1.58 Release. Include SwiftError in to the session publisher 
- 28-11-2022. 1.56 Release
- 20-09-2022. 1.43 Release 
