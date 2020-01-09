//
//  AppDelegate.swift
//
//  Copyright © 2020 Rosberry. All rights reserved.
//

import UIKit
import ButterBroad
import Firebase

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        FirebaseApp.configure()
        return true
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        Butter.facebook.activate()
    }

    func applicationWillTerminate(_ application: UIApplication) {
        
    }
}

