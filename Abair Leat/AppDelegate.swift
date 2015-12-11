//
//  AppDelegate.swift
//  Abair Leat
//
//  Created by Aaron Signorelli on 19/11/2015.
//  Copyright © 2015 Superpixel. All rights reserved.
//

import UIKit
import FBSDKCoreKit
import Firebase

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    
    var window: UIWindow?

    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
        FBSDKApplicationDelegate.sharedInstance().application(application, didFinishLaunchingWithOptions: launchOptions)
        return true
    }

    func applicationDidBecomeActive(application: UIApplication) {
        FBSDKAppEvents.activateApp()
    }
    
    func application(application: UIApplication, openURL url: NSURL, sourceApplication: String?, annotation: AnyObject) -> Bool {
        return FBSDKApplicationDelegate.sharedInstance().application(application, openURL: url, sourceApplication: sourceApplication, annotation: annotation)
    }

    func application(application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: NSData) {
        let base64EncodedToken = deviceToken.base64EncodedStringWithOptions(NSDataBase64EncodingOptions(rawValue: 0))
        AbairLeat.shared.profile.myProfileRef!.childByAppendingPath("iosNotificationToken").setValue(base64EncodedToken)
    }
    
}

