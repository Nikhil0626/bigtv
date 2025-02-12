import Flutter
import UIKit
import FirebaseCore
import FirebaseDynamicLinks
import WebEngage

@main
@objc class AppDelegate: FlutterAppDelegate {
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
      FirebaseApp.configure()
      WebEngage.sharedInstance().application(application, didFinishLaunchingWithOptions: launchOptions)

    GeneratedPluginRegistrant.register(with: self)
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }


}
