//
//  ExtensionMyFestaStoryViewController.swift
//  MakeFairytale
//
//  Created by ByungHoon Ann on 2020/02/13.
//  Copyright © 2020 ByungHoon Ann. All rights reserved.
//

import UIKit
import Firebase

fileprivate let firestoreRef = Firestore.firestore()
fileprivate let currentUID = Auth.auth().currentUser?.uid

extension MyFestaStoryViewController {
    func followingCheckButton(_ followButton: UIButton,
                              _ dateFomatter: DateFormatter,
                              _ appDelegate: AppDelegate,
                              _ secondView: MyPostTableView ) {
        appDelegate.checkNotificationCheck = true
        guard let currentUID = currentUID else { return }
        let checkDate = dateFomatter.string(from: appDelegate.date)
        let secondUID = secondView.yourUID
        let firestoreFollowRef = firestoreRef.collection("Follow")
        guard let myName = appDelegate.myProfile?.nickName else { return }
        
        if !secondUID.isEmpty {
            firestoreRef
                .collection("user")
                .document("\(secondUID)")
                .getDocument { userData, error in
                    guard let userData = userData?.data() else { return }
                    let profile = userData["profileImageURL"] as? String ?? ""
                    let nickName = userData["nickName"] as? String ?? ""
                    
                    let myUrlkey = firestoreFollowRef
                        .document(currentUID)
                        .collection("FollowList")
                        .document(secondUID)
                        .documentID
                    
                    let yourUrlKey = firestoreRef
                        .collection("Follower")
                        .document(secondUID)
                        .collection("FollowerList")
                        .document(currentUID)
                        .documentID
                    
                    firestoreFollowRef
                        .document("\(currentUID)")
                        .collection("FollowList")
                        .getDocuments { (snapshot, error) in
                            guard let snapshot = snapshot?.documents else {return}
                            
                            if snapshot.isEmpty {
                                followButton.isSelected = true
                                self.appDelegate.otherUID = currentUID
                                firestoreFollowRef
                                    .document(currentUID)
                                    .collection("FollowList")
                                    .document("\(secondUID)")
                                    .setData([
                                        "uid":secondUID,
                                        "nickName":nickName,
                                        "profileImageURL":profile,
                                        "follow":true
                                    ])
                                
                                self.notificationAlert(nickName,
                                                       checkDate,
                                                       secondUID,
                                                       currentUID,
                                                       "님을 팔로우합니다",
                                                       myUrlkey)
                                
                                firestoreRef
                                    .collection("Follower")
                                    .document(secondUID)
                                    .collection("FollowerList")
                                    .document(currentUID)
                                    .setData([
                                        "uid":currentUID,
                                        "nickName":nickName,
                                        "profileImageURL":profile,
                                        "follower":true
                                    ])
                                
                                self.notificationAlert(myName,
                                                       checkDate,
                                                       currentUID,
                                                       secondUID,
                                                       "님이 당신을 팔로우합니다",
                                                       yourUrlKey)
                                
                                self.alertContentsCenter("follow",
                                                         secondUID)
                            } else {
                                for i in snapshot {
                                    let data = i.data()
                                    let uid = data["uid"] as? String ?? ""
                                    let followCheck = data["follow"] as? Bool ?? false
                                    
                                    if uid == secondUID, followCheck == true {
                                        followButton.isSelected = false
                                        
                                        firestoreRef.collection("Follow")
                                            .document(currentUID)
                                            .collection("FollowList")
                                            .document("\(secondUID)")
                                            .delete()
                                        
                                        self.notificationAlert(nickName,
                                                               checkDate,
                                                               secondUID,
                                                               currentUID,
                                                               "님을 언팔로우합니다",
                                                               myUrlkey)
                                        
                                        self.notificationAlert(myName,
                                                               checkDate,
                                                               currentUID,
                                                               secondUID,
                                                               "님이 당신을 언팔로우합니다",
                                                               yourUrlKey)
                                        
                                         self.alertContentsCenter("follow",
                                                                  secondUID)
                                        break
                                    } else {
                                        followButton.isSelected = true
                                        firestoreFollowRef
                                            .document(currentUID)
                                            .collection("FollowList")
                                            .document("\(secondUID)")
                                            .setData([
                                                "uid":secondUID,
                                                "nickName":nickName,
                                                "profileImageURL":profile,
                                                "follow":true
                                            ])
                                    }
                                }
                            }}
            }
        }
    }
}
