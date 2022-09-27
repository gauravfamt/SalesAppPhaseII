import UIKit
import Flutter
//import workmanager
import sqflite
import flutter_downloader

@UIApplicationMain
@objc class AppDelegate: FlutterAppDelegate {
  override func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
      
//      GeneratedPluginRegistrant.register(with: self)
//      UNUserNotificationCenter.current().delegate = self
//      UIApplication.shared.setMinimumBackgroundFetchInterval(TimeInterval(5))
//      WorkmanagerPlugin.setPluginRegistrantCallback { registry in
//          // registry in this case is the FlutterEngine that is created in Workmanager's performFetchWithCompletionHandler
//          // This will make other plugins available during a background fetch
//          GeneratedPluginRegistrant.register(with: registry)
//      }
    
    GeneratedPluginRegistrant.register(with: self)
    FlutterDownloaderPlugin.setPluginRegistrantCallback(registerPlugins)
    let controller: FlutterViewController = window?.rootViewController as! FlutterViewController
    let methodChannel = FlutterMethodChannel(name: "com.example.sqflite/backgrounded", binaryMessenger: controller as! FlutterBinaryMessenger)
    
    methodChannel.setMethodCallHandler { call, result in
        let array = call.arguments as! Array<Any>
        let handle = array[0] as! Int64
        
        // Create it here to avoid registration issue the second time
        // Not sure if that's correct though
        let backgroundEngine = FlutterEngine(name: "BackgroundIsolate", project: nil, allowHeadlessExecution: true)
        
        let callbackInformation = FlutterCallbackCache.lookupCallbackInformation(handle)
        backgroundEngine.run(withEntrypoint: callbackInformation?.callbackName, libraryURI: callbackInformation?.callbackLibraryPath)
        
        SqflitePlugin.register(with: backgroundEngine.registrar(forPlugin: "com.tekartik.sqflite.SqflitePlugin"))
        
        result(nil)
    }
      
      return super.application(application, didFinishLaunchingWithOptions: launchOptions)
      
  }
  
  override func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
       completionHandler(.alert) // shows banner even if app is in foreground
   }
}
private func registerPlugins(registry: FlutterPluginRegistry) {
    if (!registry.hasPlugin("FlutterDownloaderPlugin")) {
       FlutterDownloaderPlugin.register(with: registry.registrar(forPlugin: "FlutterDownloaderPlugin"))
    }
}

