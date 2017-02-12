//
//  AppDelegate.swift
//  ColorfulButton
//
//  Created by zhi zhou on 2017/1/19.
//  Copyright © 2017年 zhi zhou. All rights reserved.
//

import UIKit

/// SQL 表名
let tableName = "t_buttons"

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?


    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        
        SQLite.shared.isPrint = false
        _ = SQLite.shared.openDB(tableName: tableName)
        
        UINavigationBar.appearance().tintColor = appColor
        
        return true
    }

    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
        
        NotificationCenter.default.post(Notification(name: appWillResignActiveNotification))
        
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
        
        NotificationCenter.default.post(Notification(name: appDidEnterBackgroundNotification))
        
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
        
        NotificationCenter.default.post(Notification(name: appWillEnterForegroundNotification))
        
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
        
        NotificationCenter.default.post(Notification(name: appDidBecomeActiveNotification))
        
    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
        
        NotificationCenter.default.post(Notification(name: appWillTerminateNotification))
        
    }

}
