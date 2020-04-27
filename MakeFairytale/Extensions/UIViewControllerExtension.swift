//
//  ExtensionViewController.swift
//  MakeFairytale
//
//  Created by ByungHoon Ann on 2020/02/08.
//  Copyright © 2020 ByungHoon Ann. All rights reserved.
//

import UIKit
import Firebase

fileprivate let firestoreRef = Firestore.firestore()

extension UIViewController {
    
    //FIXME:- 좋아요 func
    func likeButtonAction(_ checkDate: String,
                          _ post: Posts,
                          _ sender: UIButton,
                          _ currentUID: String,
                          completion : @escaping () -> Void) {
        guard let myName = FirebaseServices.shread.myProfile?.nickName else { return }
        let myMessage = "님의 게시물에 좋아요를 누르셨습니다."
        let yourMessage = "께서 게시물에 좋아요를 누르셨습니다."
        let myCancel = "님의 게시물의 좋아요를 취소하셨습니다."
        let yourCancel = "님께서 게시물의 좋아요를 취소하셨습니다."
        firestoreRef
            .collection("AllPost")
            .order(by: post.userUID)
            .getDocuments { snapshot,error in
                guard let snapshot = snapshot?.documents else { return }
                for i in snapshot {
                    guard let data = i.data() as? [String:[String:Any]] else { return}
                    for (_,j) in data {
                        guard let postImage = j["postImageURL"] as? [String] else { return }
                        if postImage[0] == post.userPostImage[0] {
                            let urlKey = i.documentID
                            let likeRef = Firestore
                                .getOtherRef("AllPost", urlKey)
                                .collection("goodMarkLog")
                                .document(currentUID)
                            likeRef.getDocument { likeCheck, error in
                                    
                                    guard let likeCheck = likeCheck?.data() else {
                                        sender.isSelected = true
                                        likeRef.setData([
                                                "like":true,
                                                "checkDate":checkDate
                                            ])
                                        self.notificationAlert(myName,
                                                               checkDate,
                                                               post.userUID,
                                                               currentUID,
                                                               myMessage,
                                                               urlKey)
                                        if post.userUID != currentUID {
                                            self.notificationAlert(myName,
                                                               checkDate,
                                                               currentUID,
                                                               post.userUID,
                                                               yourMessage,
                                                               urlKey)
                                            self.alertContentsCenter("like", post.userUID)
                                        }
                                        return completion()
                                }
                                
                                let myLike = likeCheck["like"] as? Bool ?? false
                                if myLike == true {
                                    sender.isSelected = false
                                    
                                    likeRef.setData([
                                        "like":false,
                                        "checkDate":checkDate
                                    ])
                                    
                                    self.notificationAlert(post.userName,
                                                           checkDate,
                                                           currentUID,
                                                           post.userUID,
                                                           yourCancel,
                                                           urlKey)
                                    print(post.userName,"sdsd")
                                        
                                        if post.userUID != currentUID {
                                            print(post.userName,myCancel,"ddd")
                                            self.notificationAlert(post.userName,
                                                                   checkDate,
                                                                   post.userUID,
                                                                   currentUID,
                                                                   myCancel,
                                                                   urlKey)
                                        }
                                        completion()
                                    } else if myLike == false {
                                        sender.isSelected = true
                                        likeRef.setData([
                                            "like":true,
                                            "checkDate":checkDate
                                        ])
                                        
                                    self.notificationAlert(post.userName,
                                                               checkDate,
                                                               currentUID,
                                                               post.userUID,
                                                               myMessage,
                                                               urlKey)
                                        self.alertContentsCenter("like",
                                                                 post.userUID)
                                        
                                        if post.userUID != currentUID {
                                            self.notificationAlert(post.userName,
                                                               checkDate,
                                                               post.userUID,
                                                               currentUID,
                                                               myMessage,
                                                               urlKey)
                                        }
                                        completion()
                                    }
                            }
                        }
                    }
                }
        }
    }
    
    //MARK:- 알림센터 Message 송신 Event Func
    func notificationAlert(_ name: String,
                           _ date: String,
                           _ myUid: String,
                           _ yourUid: String,
                           _ message: String,
                           _ url: String) {
        
        firestoreRef
            .collection("NotificationCenter")
            .document(yourUid)
            .collection("alert")
            .addDocument(data:
                ["nickName":name,
                 "uid":myUid,
                 "date":date,
                 "message":"\(name)\(message)",
                    "url":url
            ]) { error in
                if let error = error { print("notification error! = \(error.localizedDescription)") }
        }
    }
    
    //MARK:- 알림 감지를 변수를 분별하기 위한 함수
    func alertContentsCenter(_ alertContent: String, _ yourUid: String) {
        switch alertContent {
        case "like":
            firestoreRef.collection("user").document(yourUid).updateData(["like":true])
        case "chatting":
            firestoreRef.collection("user").document(yourUid).updateData(["chatting":true])
        case "follow":
            firestoreRef.collection("user").document(yourUid).updateData(["follow":true])
        case "post" :
            firestoreRef.collection("user").document(yourUid).updateData(["newPost":true])
        case "reple" :
            firestoreRef.collection("user").document(yourUid).updateData(["reple":true])
        default :
            print("error!")
        }
    }
    
    func moveDetailViewPostView(_ view: MyViews, _ path: Int) {
        let i = IndexPath(row:path, section: 0)
        guard let vc = UIStoryboard.viewPostingVC() else { return }
        vc.post = view.myPosts[i.row]
        navigationController?.pushViewController(vc, animated: true)
    }
}

extension UIViewController: UNUserNotificationCenterDelegate {
    public func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        print("notificationcenter will Present \(notification)")
        completionHandler([.alert, .sound,.badge])
    }

    public func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
        print("notificationcenter did Present \(response)")
        completionHandler()
    }
}



