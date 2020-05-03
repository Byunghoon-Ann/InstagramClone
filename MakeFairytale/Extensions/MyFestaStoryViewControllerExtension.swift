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
fileprivate let notifiRef = Firestore.firestore().collection("NotificationCenter")
extension MyFestaStoryViewController {
    func followingCheckButton(_ followButton: UIButton,
                              _ dateFomatter: DateFormatter,
                              _ secondView: MyPostTableView ) {
        State.shread.checkNotificationCheck = true
        guard let currentUID = CurrentUID.shread.currentUID else { return }
        let checkDate = dateFomatter.string(from: Today.shread.today)
        let secondUID = secondView.yourUID
        guard let myName = FirebaseServices.shread.myProfile?.nickName else { return }
        let yourUID = CurrentUID.shread.yourUID
        if !yourUID.isEmpty {
            let yourRef = Firestore.getOtherRef("user",yourUID) //se
            let yourfollowRef = Firestore.getOtherRef("Follow", currentUID).collection("FollowList")
            
            yourRef.getDocument { [weak self] userData, error in
                    guard let self = self else { return }
                    guard let userData = userData?.data() else { return }
                    let profile = userData["profileImageURL"] as? String ?? ""
                    let nickName = userData["nickName"] as? String ?? ""
                let myUrlkey = yourfollowRef.document(yourUID).documentID
                    
                    yourfollowRef.getDocuments { (snapshot, error) in
                            guard let snapshot = snapshot?.documents else {return}
                            
                            if snapshot.isEmpty {
                                followButton.isSelected = true
                                yourfollowRef
                                    .document("\(yourUID)")
                                    .setData([
                                        "uid":yourUID,
                                        "nickName":nickName,
                                        "profileImageURL":profile,
                                        "follow":true,
                                        "data":checkDate
                                    ])
                                
                                followerRef
                                    .document(yourUID)
                                    .collection("FollowerList")
                                    .document(currentUID)
                                    .setData([
                                        "uid":currentUID,
                                        "nickName":nickName,
                                        "profileImageURL":profile,
                                        "follower":true,
                                        "date":checkDate
                                    ]) { error in
                                        if let _error = error { print("\(_error.localizedDescription)")}
                                        self.followNotfication(myName,
                                                               nickName,
                                                               currentUID,
                                                               self.yourUID, //
                                                               checkDate,
                                                               myUrlkey,
                                                               follow: true)
                                }
                            } else {
                                for i in snapshot {
                                    let data = i.data()
                                    let uid = data["uid"] as? String ?? ""
                                    let followCheck = data["follow"] as? Bool ?? false
                                    
                                    if uid == secondUID, followCheck == true {
                                        followButton.isSelected = false
                                        
                                        yourfollowRef
                                            .document("\(yourUID)")
                                            .delete()
                                        
                                        self.followNotfication(myName,
                                                               nickName,
                                                               currentUID,
                                                               yourUID,
                                                               checkDate,
                                                               myUrlkey,
                                                               follow: false)
                                        break
                                    } else {
                                        followButton.isSelected = true
                                        yourfollowRef
                                            .document("\(yourUID)")
                                            .setData([
                                                "uid":yourUID,
                                                "nickName":nickName,
                                                "profileImageURL":profile,
                                                "follow":true,
                                                "date":checkDate
                                            ]) { error in
                                                if let _error = error { print("\(_error.localizedDescription)")}
                                                self.followNotfication(myName,
                                                                       nickName,
                                                                       currentUID,
                                                                       yourUID, //
                                                                       checkDate,
                                                                       myUrlkey,
                                                                       follow: true)
                                        }
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

        if !yourUID.isEmpty {
            let followingRef = Firestore.firestore().followingRef(yourUID) //se
            let followerRef = Firestore.firestore().followerRef(yourUID) // se
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
    
    func followNotfication(_ myName:String, _ yourName: String, _ myUid: String, _ yourUID: String, _ date: String, _ url: String, follow: Bool) {
        let yourRef = notifiRef.document(yourUID).collection("alert")
        let myRef = notifiRef.document(myUid).collection("alert")
        let myMessage = "\(yourName)님을 팔로우합니다."
        let yourMessage = "\(myName)님이 당신을 팔로우합니다."
        let myCancel = "\(yourName)님을 언팔로우합니다."
        let yourCancel = "\(myName)님이 당신을 언팔로우합니다"
        
        if follow == true {
            yourRef.addDocument(data: ["nickName":myName,
                                       "date":date,
                                       "uid": myUid,
                                       "url":url,
                                       "message":yourMessage]) { error in
                                        if let _error = error { print("\(_error.localizedDescription)")}
                                        
                                        Firestore.firestore().alertContentsCenter("follow", yourUID)
                                        
                                        myRef.addDocument(data: ["nickName":myName,
                                                                 "date":date,
                                                                 "uid": myUid,
                                                                 "url":url,
                                                                 "message":myMessage])
            }
        } else {
            yourRef.addDocument(data: ["nickName":myName,
                                       "date":date,
                                       "uid": myUid,
                                       "url":url,
                                       "message":yourCancel]) { error in
                                        if let _error = error { print("\(_error.localizedDescription)") }
                                        myRef.addDocument(data: ["nickName":myName,
                                                                 "date":date,
                                                                 "uid": myUid,
                                                                 "url":url,
                                                                 "message":myCancel])
            }
        }
    }
}
