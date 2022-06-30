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

## Interface

### - Class Session:
#### - func initialize(_ scope: [String]?)
####    scope - your Google Cloud app sensitive scopes (must be verified):
<img width="496" alt="Screenshot 2022-06-30 at 06 53 48" src="https://user-images.githubusercontent.com/2775621/176594084-2397a49f-7539-488b-81c2-a5ce0c0eaaf6.png">
   
   for example "https://www.googleapis.com/auth/youtube.readonly"


## How to use it:

- initialize the package:

   import SwiftGoogleSignIn

   func application(_ application: UIApplication,
                    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
      ...

      // There are needed sensitive scopes to have ability to work properly
      // Make sure they are presented in your app. Then send request on an verification
      let googleAPIscopePermissions = [
          "https://www.googleapis.com/auth/youtube",
          "https://www.googleapis.com/auth/youtube.readonly",
          "https://www.googleapis.com/auth/youtube.force-ssl"
   
      SignInAppDelegate(googleAPIscopePermissions).application(application,
         didFinishLaunchingWithOptions: launchOptions)
      ...    
    
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
