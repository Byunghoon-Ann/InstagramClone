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
fileprivate let postRef = Firestore.firestore().posts
extension UIViewController {
    //FIXME:- 좋아요 func
    func likeButtonAction(_ checkDate: String,
                          _ post: Posts,
                          _ currentUID: String,
                          completion : @escaping () -> Void) {
        guard let myName = FirebaseServices.shread.myProfile?.nickName else { return }
        
        firestoreRef
            .collection("AllPost")
            .order(by: post.userUID)
            .getDocuments { [weak self] snapshot,error in
                guard let self = self else { return }
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
                                    likeRef.setData([
                                        "like":true,
                                        "checkDate":checkDate
                                    ])
                                    
                                    self.notificationAlert(myName,
                                                           post.userName,
                                                           true,
                                                           checkDate,
                                                           currentUID,
                                                           post.userUID,
                                                           urlKey)
                                    
                                    return completion()
                                }
                                
                                let myLike = likeCheck["like"] as? Bool ?? false
                                if myLike == true {
                                    
                                    likeRef.setData([
                                        "like":false,
                                        "checkDate":checkDate
                                    ])
                                    self.notificationAlert(myName,
                                                           post.userName,
                                                           false,
                                                           checkDate,
                                                           currentUID,
                                                           post.userUID,
                                                           urlKey)
                                    
                                    completion()
                                } else if myLike == false {
                                    likeRef.setData([
                                        "like":true,
                                        "checkDate":checkDate
                                    ])
                                    self.notificationAlert(myName,
                                                           post.userName,
                                                           true,
                                                           checkDate,
                                                           currentUID,
                                                           post.userUID,
                                                           urlKey)
                                    completion()
                                }
                            }
                        }
                    }
                }
        }
    }
    
    //MARK:- 알림센터 Message 송신 Event Func
    func notificationAlert(_ myName: String,
                           _ yourName: String,
                           _ like: Bool,
                           _ date: String,
                           _ myUid: String,
                           _ yourUid: String,
                           _ url: String) {
        
        let myMessage = "\(yourName)님의 게시물에 좋아요를 누르셨습니다."
        let yourMessage = "\(myName)님께서 당신의 게시물에 좋아요를 누르셨습니다."
        let myCancel = "\(yourName)님의 게시물의 좋아요를 취소하셨습니다."
        let yourCancel = "\(myName)님께서 당신의 게시물에 좋아요를 취소하셨습니다."
        let selfLike = "당신의 게시물에 좋아요를 누르셨습니다."
        let selfCancel = "당신의 게시물에 좋아요를 취소하셨습니다."
        
        let myRef = firestoreRef.collection("NotificationCenter").document(myUid).collection("alert")
        let yourRef = firestoreRef.collection("NotificationCenter").document(yourUid).collection("alert")
        
        if yourUid == myUid {
            if like == true {
                yourRef.addDocument(data: ["nickName":myName,
                                           "date":date,
                                           "uid":myUid,
                                           "url":url,
                                           "message":selfLike])
            }else {
                yourRef.addDocument(data: ["nickName":myName,
                                           "date":date,
                                           "uid":myUid,
                                           "url":url,
                                           "message":selfCancel])
            }
        } else {
            if like == true {
                yourRef.addDocument(data: ["nickName":myName,
                                           "date":date,
                                           "uid":myUid,
                                           "url":url,
                                           "message":yourMessage]) { error in
                                            Firestore.firestore().alertContentsCenter("like", yourUid)
                                            
                                            myRef.addDocument(data: ["nickName":myName,
                                                                     "date":date,
                                                                     "uid":myUid,
                                                                     "url":url,
                                                                     "message":myMessage])
                }
            } else {
                yourRef.addDocument(data: ["nickName":myName,
                                           "date":date,
                                           "uid":myUid,
                                           "url":url,
                                           "message":yourCancel]) { error in
                                            myRef.addDocument(data: ["nickName":myName,
                                                                     "date":date,
                                                                     "uid":myUid,
                                                                     "url":url,
                                                                     "message":myCancel])
                }
            }
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
        completionHandler([.alert, .sound,.badge])
    }
    
    public func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
        completionHandler()
    }
}



