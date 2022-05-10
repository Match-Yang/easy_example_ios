//
//  AppDelegate.swift
//  ZegoEasyExample
//
//  Created by Larry on 2022/4/8.
//

import UIKit
import ZegoExpressEngine

@main
class AppDelegate: UIResponder, UIApplicationDelegate {
    var window: UIWindow?
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        self.window = UIWindow(frame:UIScreen.main.bounds)

        let rootVC = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "HomeVC")
        self.window!.rootViewController = rootVC
        self.window!.makeKeyAndVisible()

        // create engine
        ZegoExpressManager.shared.createEngine(appID: AppCenter.appID)
        return true
    }
}

