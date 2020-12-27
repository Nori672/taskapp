//
//  AppDelegate.swift
//  taskapp
//
//  Created by Norihiro.Nakano on 2020/12/09.
//  Copyright © 2020 Norihiro.Nakano. All rights reserved.
//

import UIKit
import UserNotifications

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate, UNUserNotificationCenterDelegate {



    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        
        //ユーザーに通知の許可を求める
        let center = UNUserNotificationCenter.current()
        //UNUserNotificationCenter:アプリまたはアプリ拡張機能の通知関連を管理するオブジェクト
        //current(): UNUserNotificationCenterに入っているメソッドで、通知を取得する。通知を取得するには常にこのメソッドを使用すること。
        center.requestAuthorization(options: [.alert, .sound]) { (granted, error) in
        }
        //requestAuthorization:通知を承認するかを要求するメソッド
        //granted:通知が許可がされたかを示すBool値。通知が許可されるとtrue,拒否されるとfalse
        
        center.delegate = self
        
        return true
    }
    
    //アプリがフォアグラウンド（アプリ表示中）のときに通知を受け取るを呼ばれるメソッド
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        completionHandler([.alert, .sound])
    }

    // MARK: UISceneSession Lifecycle

    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        // Called when a new scene session is being created.
        // Use this method to select a configuration to create the new scene with.
        return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
    }

    func application(_ application: UIApplication, didDiscardSceneSessions sceneSessions: Set<UISceneSession>) {
        // Called when the user discards a scene session.
        // If any sessions were discarded while the application was not running, this will be called shortly after application:didFinishLaunchingWithOptions.
        // Use this method to release any resources that were specific to the discarded scenes, as they will not return.
    }


}

