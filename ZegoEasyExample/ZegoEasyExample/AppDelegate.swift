//
//  AppDelegate.swift
//  ZegoEasyExample
//
//  Created by Larry on 2022/4/8.
//

import UIKit
import ZegoExpressEngine
import Firebase

@main
class AppDelegate: UIResponder, UIApplicationDelegate {
    
    
    var window: UIWindow?
    var fcmToken: String?
    var rootVC: ViewController?
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        FirebaseApp.configure()
        registerNotification()

        Messaging.messaging().delegate = self
        Messaging.messaging().token { token, error in
          if let error = error {
            print("Error fetching FCM registration token: \(error)")
          } else if let token = token {
            print("FCM registration token: \(token)")
          }
        }
        
        self.window = UIWindow(frame:UIScreen.main.bounds)
        rootVC = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "ViewController") as? ViewController
        self.window!.rootViewController = rootVC
        self.window!.makeKeyAndVisible()

        // create engine
        ZegoExpressManager.shared.createEngine(appID: AppCenter.appID)
        return true
    }
    
    func registerNotification() {
        UNUserNotificationCenter.current().delegate = self
        let authOptions: UNAuthorizationOptions = [.alert, .badge, .sound]
        UNUserNotificationCenter.current().requestAuthorization(options: authOptions) { authorization, error in
            
        }
        UIApplication.shared.registerForRemoteNotifications()
    }
        
}

extension AppDelegate: MessagingDelegate {
    func messaging(_ messaging: Messaging, didReceiveRegistrationToken fcmToken: String?) {
      print("Firebase registration token: \(String(describing: fcmToken))")
      let dataDict: [String: String] = ["token": fcmToken ?? ""]
      NotificationCenter.default.post(
        name: Notification.Name("FCMToken"),
        object: nil,
        userInfo: dataDict
      )
        self.fcmToken = fcmToken
      // TODO: If necessary send token to application server.
      // Note: This callback is fired at each app startup and whenever a new token is generated.
    }

}

extension AppDelegate: UNUserNotificationCenterDelegate {
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        let userInfo = notification.request.content.userInfo
        showCallTipView(userInfo)
        print(userInfo)
        completionHandler([[]])
    }

    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
        let userInfo = response.notification.request.content.userInfo
        print(userInfo)
        showCallTipView(userInfo)
        completionHandler()
    }
    
    func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable : Any], fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
        // Print full message.
        print(userInfo)
//        showCallTipView(userInfo)
        completionHandler(UIBackgroundFetchResult.newData)
    }
    
    func showCallTipView(_ callDict: [AnyHashable: Any]) {
        rootVC?.callData = callDict
        let callType = callDict["callType"] as? String
        if callType == "Video" {
            let tipView: CallAcceptTipView = CallAcceptTipView.showTipView(.video)
            tipView.delegate = rootVC
        } else {
            let tipView: CallAcceptTipView = CallAcceptTipView.showTipView(.voice)
            tipView.delegate = rootVC
        }
    }
}
