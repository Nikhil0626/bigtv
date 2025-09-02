import Flutter
import google_mobile_ads
import UIKit
import FirebaseCore
//import FirebaseDynamicLinks
import WebEngage
import webengage_flutter

@main
@objc class AppDelegate: FlutterAppDelegate {
    var bridge: WebEngagePlugin? = nil
    override func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
    ) -> Bool {
        FirebaseApp.configure()

        bridge = WebEngagePlugin()
        WebEngage.sharedInstance().pushNotificationDelegate = bridge
        WebEngage.sharedInstance().application(
            application, didFinishLaunchingWithOptions: launchOptions)
        GeneratedPluginRegistrant.register(with: self)
        GADMobileAds.sharedInstance().start(completionHandler: nil)

        let nativeAdFactory = NativeAdFactoryExample()
        FLTGoogleMobileAdsPlugin.registerNativeAdFactory(
            self,
            factoryId: "adFactoryExample",
            nativeAdFactory: nativeAdFactory as! FLTNativeAdFactory
        )

        if #available(iOS 10.0, *) {
            UNUserNotificationCenter.current().delegate = self as? UNUserNotificationCenterDelegate
        }

        return super.application(application, didFinishLaunchingWithOptions: launchOptions)
    }

    @available(iOS 10.0, *)
    override
        func userNotificationCenter(
            _ center: UNUserNotificationCenter,
            willPresent notification: UNNotification,
            withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions)
                -> Void
        )
    {

        print("center: ", center, "\nnotification: ", notification)

        WEGManualIntegration.userNotificationCenter(center, willPresent: notification)

        completionHandler([.alert, .badge, .sound])
    }

    @available(iOS 10.0, *)
    override
        func userNotificationCenter(
            _ center: UNUserNotificationCenter,
            didReceive response: UNNotificationResponse,
            withCompletionHandler completionHandler: @escaping () -> Void
        )
    {

        print("center: ", center, " response: ", response)

        WEGManualIntegration.userNotificationCenter(center, didReceive: response)

        completionHandler()
    }
}