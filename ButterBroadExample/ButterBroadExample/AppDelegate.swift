//
//  AppDelegate.swift
//
//  Copyright © 2020 Rosberry. All rights reserved.
//

import UIKit
import ButterBroad

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        Butter.common.requestDelay = 1e10
        Butter.common.activationHandler?()
        return true
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
    }

    func applicationWillTerminate(_ application: UIApplication) {
        
    }
}

