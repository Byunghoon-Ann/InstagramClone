//
//  AppDelegate.swift
//  MakeFairytale
//
//  Created by ByungHoon Ann on 16/09/2019.
//  Copyright © 2019 ByungHoon Ann. All rights reserved.
//

import UIKit
import Firebase
fileprivate let currentUID = Auth.auth().currentUser?.uid
@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
   
    var window: UIWindow?
    var currentUID: String?
    var notificationContents: String?
    var otherUID : String?
    var topViewHeight: Double?
    var tableCellHeight: CGFloat?
    var autoRefreshingCheck = false
    var sideViewBadgeCheck = false
    var chattingCheck = false
    var listFeedVC : ListViewController? = nil
    var checkNotificationCheck = false
    var myProfile : MyProfile?
    var post: [Posts] = [] //전체 포스팅 데이터
    var myPost: [Posts] = [] //사용 유저의 포스팅 데이터
    var goodPost : [Posts] = [] //좋아요가 체크된 게시물 데이터
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        sleep(1)
        UITabBar.appearance().tintColor = .white
        post.removeAll()
        myPost.removeAll()
        FirebaseApp.configure()
        return true
    }
   
    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }
    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }
}


/*
 func notificationObserver(_ contents: String) {
     var message = ""
     let center = UNUserNotificationCenter.current()
     let content = UNMutableNotificationContent()
     center.delegate = self
     center.requestAuthorization(options: [.alert,.sound,.badge]) { granted, error in
         print("granted = \(granted)")
     }
     
     NotificationCenter.default.addObserver(forName: NSNotification.Name(rawValue: contents), object: nil, queue: .main) { noti in
         print(noti)
         switch contents {
         case "like":
             content.title = "좋아요"
             message = "누군가 당신의 게시물에 좋아요를 누르셨습니다."
         case "chatting":
             content.title = "채팅"
             message = "누군가 당신에게 대화를 걸었습니다."
         case "follow":
             content.title = "팔로우"
             message = "누군가 당신을 팔로우합니다."
         case "newPost":
             content.title = "새 게시글"
             message = "팔로우한 유저 중 한명이 새로운 글을 올렸습니다."
         case "reple":
             content.title = "댓글"
             message = "누군가 당신의 게시글에 댓글을 남겼습니다."
         default:
             print("error")
         }
         content.body = message
         content.sound = UNNotificationSound.default
         content.categoryIdentifier = "image-message"
         let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 1, repeats: false)
         let requeset = UNNotificationRequest(identifier: "Alert", content: content, trigger: trigger)
         center.add(requeset) { error in
             if let error = error { print("error : \(error)")}
         }
     }
 }
 
 func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
       print("notificationcenter will Present \(notification)")
       completionHandler([.alert, .sound,.badge])
   }

   func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
       print("notificationcenter did Present \(response)")
       completionHandler()
   }
 */
