//
//  ExtensionMyFestaStoryViewController.swift
//  MakeFairytale
//
//  Created by ByungHoon Ann on 2020/02/13.
//  Copyright © 2020 ByungHoon Ann. All rights reserved.
//

import UIKit
import Firebase

fileprivate let followerRef = Firestore.firestore().follower
fileprivate let followRef = Firestore.firestore().follow

extension MyFestaStoryViewController {
    func followingCheckButton(_ followButton: UIButton,
                              _ dateFomatter: DateFormatter,
                              _ secondView: MyPostTableView ) {
        State.shread.checkNotificationCheck = true
        guard let currentUID = CurrentUID.shread.currentUID else { return }
        let checkDate = dateFomatter.string(from: Today.shread.today)
        let secondUID = secondView.yourUID
        guard let myName = FirebaseServices.shread.myProfile?.nickName else { return }
        
        if !secondUID.isEmpty {
            let yourRef = Firestore.getOtherRef("user",secondUID)
            let yourfollowRef = Firestore.getOtherRef("Follow", currentUID).collection("FollowList")
            yourRef
                .getDocument { [weak self] userData, error in
                    guard let self = self else { return }
                    guard let userData = userData?.data() else { return }
                    let profile = userData["profileImageURL"] as? String ?? ""
                    let nickName = userData["nickName"] as? String ?? ""
                    
                    let myUrlkey = yourfollowRef
                        .document(secondUID)
                        .documentID
                    
                    let yourUrlKey = followerRef
                        .document(secondUID)
                        .collection("FollowerList")
                        .document(currentUID)
                        .documentID
                    
                    yourfollowRef
                        .getDocuments { (snapshot, error) in
                            guard let snapshot = snapshot?.documents else {return}
                            
                            if snapshot.isEmpty {
                                followButton.isSelected = true
                                yourfollowRef
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
                                
                                followerRef
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
                                        
                                        yourfollowRef
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
                                        yourfollowRef
                                            .document("\(secondUID)")
                                            .setData([
                                                "uid":secondUID,
                                                "nickName":nickName,
                                                "profileImageURL":profile,
                                                "follow":true
                                            ])
                                    }
                                }
                            }
                    }
            }
        }
    }
    
    func loadFollowCount() {
        guard let currentUID = CurrentUID.shread.currentUID else { return }
        let myFollwingRef = Firestore.firestore().followingRef(currentUID)
        let myFollowerRef = Firestore.firestore().followerRef(currentUID)
        if secondMyview.yourUID != "" {
            let followingRef = Firestore.firestore().followingRef(secondMyview.yourUID)
            let followerRef = Firestore.firestore().followerRef(secondMyview.yourUID)
            followingRef
                .getDocuments { snapshot,error in
                    
                    guard let snapshot = snapshot?.documents else { return }
                    for i in snapshot {
                        let data = i.data()
                        let uid = data["uid"] as? String ?? ""
                        self.followingCheck.append(uid)
                    }
                    if let followCountLabel = self.horizontalStackView.arrangedSubviews[2] as? UILabel {
                        followCountLabel.text = "\(snapshot.count)"
                    }
            }
            
            followerRef
                .getDocuments{ snapshot , error in
                    guard let snapshot = snapshot?.documents else {return}
                    for i in snapshot {
                        let data = i.data()
                        let uid = data["uid"] as? String ?? ""
                        self.followerCheck.append(uid)
                    }
                    if let followCountLabel = self.horizontalStackView.arrangedSubviews[1] as? UILabel {
                        followCountLabel.text = "\(snapshot.count)"
                    }
            }
        } else {
            myFollowerRef
                .getDocuments { snapshot, error in
                    guard let snapshot = snapshot?.documents else {return}
                    
                    for i in snapshot {
                        let data = i.data()
                        let uid = data["uid"] as? String ?? ""
                        self.followerCheck.append(uid)
                    }
                    if let followCountLabel = self.horizontalStackView.arrangedSubviews[1] as? UILabel {
                        followCountLabel.text = "\(snapshot.count)"
                    }
            }
            
            myFollwingRef
                .getDocuments { snapshot,error in
                    guard let snapshot = snapshot?.documents else{return}
                    
                    for i in snapshot {
                        let data = i.data()
                        let uid = data["uid"] as? String ?? ""
                        self.followingCheck.append(uid)
                    }
                    if let followCountLabel = self.horizontalStackView.arrangedSubviews[2] as? UILabel {
                        followCountLabel.text = "\(snapshot.count)"
                    }
            }
        }
    }
}
