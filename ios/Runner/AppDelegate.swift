import UIKit
import Flutter
import FBSDKCoreKit
import AppTrackingTransparency
import UserNotifications
import google_mobile_ads
//import AdSupport

@main
@objc class AppDelegate: FlutterAppDelegate {
    override func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
    ) -> Bool {
        
        application.applicationIconBadgeNumber = 0
    
        let controller : FlutterViewController = window?.rootViewController as! FlutterViewController
        let channel = FlutterMethodChannel(name: "player.musicmuse.nativemethod", binaryMessenger: controller.binaryMessenger)
        channel.setMethodCallHandler({
            (call: FlutterMethodCall, result: @escaping FlutterResult) -> Void in
            if call.method == "initFacebook" {
                if let args = call.arguments as? [String: Any] {
                    if let fbid = args["fbid"] as? String,
                       let fbtoken = args["fbtoken"] as? String {
                        Settings.shared.clientToken=fbtoken
                        Settings.shared.appID=fbid
                        
                        //facebook
                        ApplicationDelegate.shared.application(
                            application,
                            didFinishLaunchingWithOptions: launchOptions
                        )
                        
                        if #available(iOS 14, *) {
                            if (ATTrackingManager.trackingAuthorizationStatus == .authorized){
                                Settings.shared.isAdvertiserTrackingEnabled = true
                            } else if(ATTrackingManager.trackingAuthorizationStatus == .notDetermined){
                                
                            } else {
                                Settings.shared.isAdvertiserTrackingEnabled = false
                            }
                        }
                        
                        result(args)
                    } else {
                        result(FlutterMethodNotImplemented)
                    }
                } else {
                    result(FlutterMethodNotImplemented)
                }
            } else {
                result(FlutterMethodNotImplemented)
            }
        })
        
        
        // GADMobileAds.sharedInstance().audioVideoManager.audioSessionIsApplicationManaged = true
        
        UNUserNotificationCenter.current().delegate = self as? UNUserNotificationCenterDelegate
        
        
        GeneratedPluginRegistrant.register(with: self)
        
        
        let homeNativeAdFactory = NativeAdFactory()
        FLTGoogleMobileAdsPlugin.registerNativeAdFactory(self, factoryId: "full_native", nativeAdFactory: homeNativeAdFactory)
        
        
        return super.application(application, didFinishLaunchingWithOptions: launchOptions)
    }
    
    //facebook
    override func application(
        _ app: UIApplication,
        open url: URL,
        options: [UIApplication.OpenURLOptionsKey : Any] = [:]
    ) -> Bool {
        ApplicationDelegate.shared.application(
            app,
            open: url,
            sourceApplication: options[UIApplication.OpenURLOptionsKey.sourceApplication] as? String,
            annotation: options[UIApplication.OpenURLOptionsKey.annotation]
        )
    }
}
