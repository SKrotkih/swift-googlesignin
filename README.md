# SwiftGoogleSignIn

SwiftGoogleSignIn is an open-source package which helps to make log in to Google account for your iOS app easy.
In fact the package is an adapter for [Google Sign-In for iOS and macOS](https://developers.google.com/identity/sign-in/ios/start).
[There is an example of using the package.](https://github.com/SKrotkih/YTLiveStreaming)

## How to install it:

- open your Xcode project for iOS
- select File-Add packages...
- in the Apple Swift Packages screen select 'Search or Enter Package URL'
- enter https://github.com/SKrotkih/SwiftGoogleSignIn.git
- make sure SwiftGoogleSignIn is opened
- press 'Add Package' 
- Xcode creates 'Package Pependencies' group with SwiftGoogleSignIn package with last version 
- open your Xcode project settings - PROJECT section on the Package Dependencies tab
- make sure the SwiftGoogleSignIn package name is presented there 

## How to use the package:

- initialize stage:

   import SwiftGoogleSignIn

   // There are needed sensitive scopes for Google APIs to have ability to work properly
   // Make sure they are presented in your app. Then send request on verification
   let googleAPIscopes: [String]? = ["https://www.googleapis.com/auth/youtube",
       "https://www.googleapis.com/auth/youtube.readonly",
       "https://www.googleapis.com/auth/youtube.force-ssl"]

   func application(_ application: UIApplication,
                    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
      SwiftGoogleSignIn.session.initialize(googleAPIscopes) // nil is a defaut value 
   }
   
   func application(_ application: UIApplication,
                    open url: URL,
                    options: [UIApplication.OpenURLOptionsKey: Any] = [:]
   ) -> Bool {
       return SwiftGoogleSignIn.session.openUrl(url)
   }
   
- put 'Sign In' button:

   import SwiftGoogleSignIn

   struct SignInBodyView: View {

      var body: some View {
         ...
         SignInButton()
         ...
      }
   }

- when the user signed in successfully then you can handle it:

   SwiftGoogleSignIn.session.user?
      .receive(on: RunLoop.main)
      .sink { in
         // $0 is a GoogleUser data
      }
      .store(in: &self.cancellableBag)
      
- or handle if something went wrong:

   SwiftGoogleSignIn.session.loginResult?
      .sink(receiveCompletion: { completion in
         switch completion {
            case .failure(let error):
               // handle the error
            default:
               break
         }
         }, receiveValue: { theUserIsLoggedIn in
            if theUserIsLoggedIn {
               // the user signed in successfully
            }
         })
         .store(in: &cancellableBag)




 Note: [There is an example of using the package.](https://github.com/SKrotkih/YTLiveStreaming)
