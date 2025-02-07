import Flutter
import UIKit
import FirebaseCore
import FirebaseDynamicLinks

@main
@objc class AppDelegate: FlutterAppDelegate {
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
      FirebaseApp.configure()
    GeneratedPluginRegistrant.register(with: self)
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }

  override func application(_ app: UIApplication, open url: URL, options: [UIApplication.OpenURLOptionsKey : Any] = [:]) -> Bool {
          if DynamicLinks.dynamicLinks().handleUniversalLink(url) { return true }
          return super.application(app, open: url, options: options)
      }

      override func application(_ application: UIApplication, continue userActivity: NSUserActivity, restorationHandler: @escaping ([UIUserActivityRestoring]?) -> Void) -> Bool {
          let handled = DynamicLinks.dynamicLinks().handleUniversalLink(userActivity.webpageURL!) { dynamicLink, error in
              if let dynamicLink = dynamicLink, let deepLinkURL = dynamicLink.url {
                  // Handle deep link inside the app
                  print("Received deep link: \(deepLinkURL.absoluteString)")
              }
          }
          return handled
      }
}
