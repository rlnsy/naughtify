import UIKit
import Flutter

@UIApplicationMain
@objc class AppDelegate: FlutterAppDelegate {
    
    override func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        GeneratedPluginRegistrant.register(with: self);
        
        let controller : FlutterViewController = window?.rootViewController as! FlutterViewController;
        let batteryChannel = FlutterMethodChannel.init(name: "com.rowlindsay/platform-methods",
                                                       binaryMessenger: controller);
        batteryChannel.setMethodCallHandler({
            (call: FlutterMethodCall, result: FlutterResult) -> Void in
            
            if ("clearNotifications" == call.method) {
                self.clearNotifications(result: result);
            } else if ("isChannelNeeded" == call.method) {
                result(false);
            } else if ("toggleMuteMode" == call.method) {
                self.toggleMuteMode(result: result);
            } else if ("getNotifications" == call.method) {
                self.getNotifications(result: result);
            } else if ("isAndroid" == call.method) {
                result(false);
            } else {
                result(FlutterMethodNotImplemented);
            }
            
        });
        
        return super.application(application, didFinishLaunchingWithOptions: launchOptions);
    }
    
    
    private func clearNotifications(result: FlutterResult) {
        // clear notifications
        result("sent clear request");
    }
    
    private func toggleMuteMode(result: FlutterResult) {
        // toggle
        result(true);
    }
    
    private func getNotifications(result: FlutterResult) {
        result("[]");
    }
    
}
