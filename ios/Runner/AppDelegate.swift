import Flutter
import google_mobile_ads
import UIKit
import FirebaseCore
import FirebaseDynamicLinks
import WebEngage
import webengage_flutter

@main
@objc class AppDelegate: FlutterAppDelegate {
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
      FirebaseApp.configure()

      WebEngage.sharedInstance().application(application, didFinishLaunchingWithOptions: launchOptions)


    GeneratedPluginRegistrant.register(with: self)
      let nativeAdFactory = NativeAdFactoryExample()
            FLTGoogleMobileAdsPlugin.registerNativeAdFactory(
                self,
                factoryId: "adFactoryExample",
                nativeAdFactory: nativeAdFactory as! FLTNativeAdFactory
            )
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }


}
