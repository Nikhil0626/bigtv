import Flutter
// import google_mobile_ads
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
        // GADMobileAds.sharedInstance().start(completionHandler: nil)

        // let nativeAdFactory = NativeAdFactoryExample()
        // FLTGoogleMobileAdsPlugin.registerNativeAdFactory(
        //     self,
        //     factoryId: "adFactoryExample",
        //     nativeAdFactory: nativeAdFactory as! FLTNativeAdFactory
        // )

        if #available(iOS 10.0, *) {
            UNUserNotificationCenter.current().delegate = self as? UNUserNotificationCenterDelegate
        }

        if let controller = window?.rootViewController as? FlutterViewController {
            let whatsappChannel = FlutterMethodChannel(name: "com.chotanews/whatsapp",
                                                      binaryMessenger: controller.binaryMessenger)
            whatsappChannel.setMethodCallHandler({ [weak self]
                (call: FlutterMethodCall, result: @escaping FlutterResult) -> Void in
                if call.method == "shareToWhatsApp" {
                    if let args = call.arguments as? [String: Any],
                       let imagePath = args["imagePath"] as? String,
                       let text = args["text"] as? String {
                        self?.shareToWhatsApp(imagePath: imagePath, text: text, result: result)
                    } else {
                        result(FlutterError(code: "INVALID_ARGUMENT", message: "Missing arguments", details: nil))
                    }
                } else {
                    result(FlutterMethodNotImplemented)
                }
            })
        }

        return super.application(application, didFinishLaunchingWithOptions: launchOptions)
    }

    var documentInteractionController: UIDocumentInteractionController?

    func shareToWhatsApp(imagePath: String, text: String, result: @escaping FlutterResult) {
        let whatsAppURL = URL(string: "whatsapp://app")!
        if UIApplication.shared.canOpenURL(whatsAppURL) {
            // Copy text to clipboard as WhatsApp iOS drops text when sharing image
            UIPasteboard.general.string = text
            
            let fileManager = FileManager.default
            let tempDir = NSTemporaryDirectory()
            let waiPath = (tempDir as NSString).appendingPathComponent("whatsAppTmp.wai")
            
            do {
                if fileManager.fileExists(atPath: waiPath) {
                    try fileManager.removeItem(atPath: waiPath)
                }
                try fileManager.copyItem(atPath: imagePath, toPath: waiPath)
                
                let fileURL = URL(fileURLWithPath: waiPath)
                documentInteractionController = UIDocumentInteractionController(url: fileURL)
                documentInteractionController?.uti = "net.whatsapp.image"
                
                if let rootVC = window?.rootViewController {
                    documentInteractionController?.presentOpenInMenu(from: CGRect.zero, in: rootVC.view, animated: true)
                    result(true)
                } else {
                    result(FlutterError(code: "UI_ERROR", message: "Could not find root view controller", details: nil))
                }
            } catch {
                result(FlutterError(code: "FILE_ERROR", message: "Failed to process image file", details: error.localizedDescription))
            }
        } else {
            result(FlutterError(code: "APP_NOT_INSTALLED", message: "WhatsApp is not installed", details: nil))
        }
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