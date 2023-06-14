import Foundation
import Flutter
import FBAudienceNetwork

class FANPluginFactory: NSObject {
    let channel: FlutterMethodChannel
    
    init(_channel: FlutterMethodChannel) {
        print("FANPluginFactory > init")
        
        channel = _channel
        
        super.init()
        
        channel.setMethodCallHandler { (_ call : FlutterMethodCall, result : @escaping FlutterResult) in
            switch call.method{
            case "init":
                if #available(iOS 14.0, *) {
                    let iOSAdvertiserTrackingEnabled = ((call.arguments as! Dictionary<String,AnyObject>)["iOSAdvertiserTrackingEnabled"] as! NSString).boolValue
                    print("FANPluginFactory > iOSAdvertiserTrackingEnabled: " + String(iOSAdvertiserTrackingEnabled))
                    FBAdSettings.setAdvertiserTrackingEnabled(iOSAdvertiserTrackingEnabled)
                }
                let testingIdString = (call.arguments as! Dictionary<String,AnyObject>)["testingId"] as! String
                FBAdSettings.addTestDevice(testingIdString)

                let debugLog = ((call.arguments as! Dictionary<String,AnyObject>)["debugLog"] as! NSString).boolValue
                if (debugLog) {
                    FBAdSettings.setLogLevel(FBAdLogLevel.verbose)
                    print("!!!!!FBAdSettings_testDeviceHash:\(FBAdSettings.testDeviceHash())")
                    print("!!!!!FBAdSettings_FBAdSettings:\(FBAdSettings.isTestMode())")
                }
                
                let clearTestDevices = ((call.arguments as! Dictionary<String,AnyObject>)["clearTestDevices"] as! NSString).boolValue
                if (clearTestDevices) {
                    FBAdSettings.clearTestDevices()
                }

                print("FANPluginFactory > init")
                result(true)
            default:
                result(FlutterMethodNotImplemented)
            }
        }
        
        print("FacebookAudienceNetworkInterstitialAdPlugin > init > end")
    }
}
