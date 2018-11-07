import UIKit
import Flutter

@UIApplicationMain
@objc class AppDelegate: FlutterAppDelegate {
  
    private var applicationId = "293124"
    private var deezerMethodChannel = "ikonfete_deezer_method_channel";
    
    override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?
  ) -> Bool {
        GeneratedPluginRegistrant.register(with: self)
    
        let controller : FlutterViewController = window?.rootViewController as! FlutterViewController;
        let methodChannel = FlutterMethodChannel.init(name: deezerMethodChannel,
                                                      binaryMessenger: controller)
        let deezerApi = DeezerApi.init(applicationId)
        
        methodChannel.setMethodCallHandler({
            (call: FlutterMethodCall, result: @escaping FlutterResult) -> Void in
            switch call.method {
            case "authorize":
                deezerApi.authorize(result)
            case "getAccessToken":
                deezerApi.getAccessToken(result)
            case "logout":
                deezerApi.logout(result)
            case "isSessionValid":
                deezerApi.isSessionValid(result)
            case "getCurrentUser":
                deezerApi.getCurrentUser(result)
            case "getTrack":
                let trackId = (call.arguments as! NSDictionary)["trackId"]
                deezerApi.getTrack(trackId as! Int, result)
            case "initializeTrackPlayer":
                deezerApi.initializeTrackPlayer(result)
            case "playTrack":
                print("Playing...")
                let trackId = (call.arguments as! NSDictionary)["trackId"]
                deezerApi.playTrack(trackId as! Int64, result)
            case "pause":
                deezerApi.pause()
                result(nil)
            case "resume":
                deezerApi.resume()
                result(nil)
            case "stop":
                deezerApi.stop()
                result(nil)
            case "closePlayer":
                result(nil)
            default:
                result(FlutterMethodNotImplemented)
            }
        })
        
        return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }
}
