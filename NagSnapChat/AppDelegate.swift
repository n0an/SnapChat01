//
//  AppDelegate.swift
//  NagSnapChat
//
//  Created by nag on 17.09.16.
//  Copyright © 2016 Anton Novoselov. All rights reserved.
//

import UIKit
import Parse

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        
        let configuration = ParseClientConfiguration {
            $0.applicationId = "NagSnapChat"
            $0.server = "http://188.166.13.241:1337/parse"
        }
        Parse.initialize(with: configuration)
        
        customizeAppearance()
        
        
        // ===TOUSE===
        // MARK: - PARSE PUSH NOTIFICATIONS CONFIGURATION
        
        let userNotificationTypes: UIUserNotificationType = [.alert, .badge, .sound]
        let settings = UIUserNotificationSettings(types: userNotificationTypes, categories: nil)
        
        application.registerUserNotificationSettings(settings)
        application.registerForRemoteNotifications()
        
        
        
        
        
        return true
    }
    
    func customizeAppearance() {
        let tintColor = UIColor(red: 255/255, green: 45/255, blue: 85/255, alpha: 1)
        window!.tintColor = tintColor
    }
    
    
    // ===TOUSE===
    // MARK: - PARSE PUSH NOTIFICATIONS
    
    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        let currentInstallation = PFInstallation.current()
        currentInstallation?.setDeviceTokenFrom(deviceToken)
        currentInstallation?.channels = ["global"]
        currentInstallation?.saveInBackground()
    }
    
    // Handle Push Notification Error
    
    func application(_ application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: Error) {
        if error._code == 3010 {
            print("push notifications are not supported in the ios simulator")
        } else {
            print("didFailToRegisterForRemoteNotificationsWithError: \(error.localizedDescription)")
        }
    }
    
    
    func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable: Any]) {
        NotificationCenter.default.post(name: Notification.Name(rawValue: "reloadMessages"), object: nil)
        
    }
    
    
    func application(_ application: UIApplication, didRegister notificationSettings: UIUserNotificationSettings) {
        UIApplication.shared.registerForRemoteNotifications()
    }
    
    func applicationDidBecomeActive(_ application: UIApplication) {
        
        let tabBarController = self.window?.rootViewController as! UITabBarController
        
        if let navigationController = tabBarController.viewControllers?.first as? UINavigationController {
            
            if let inboxViewController = navigationController.topViewController as? InboxViewController{
                
                let numberOfMessages = inboxViewController.messages.count
                
                UIApplication.shared.applicationIconBadgeNumber = numberOfMessages
            }
            
        }
        
        
        
        
    }
    
    
    

    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
    }

    

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }


}

