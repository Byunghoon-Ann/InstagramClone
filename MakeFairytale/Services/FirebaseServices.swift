//
//  LoadFile.swift
//  MakeFairytale
//
//  Created by ByungHoon Ann on 12/10/2019.
//  Copyright © 2019 ByungHoon Ann. All rights reserved.
//
//MARK:- 팔로우, 포스트, 전체포스트(서치뷰용) 리스트 로드 함수 파일
import Firebase
import UIKit

fileprivate let firestoreRef = Firestore.firestore()
fileprivate let postRef = firestoreRef.posts
fileprivate let userRef = firestoreRef.user
fileprivate let followRef = firestoreRef.follow
fileprivate let chatRoomRef = Database.database().reference().child("chatRooms")

class FirebaseServices {
    
    static var shread : FirebaseServices = FirebaseServices()
    
    private init() {}
    
    let appDelegate = UIApplication.shared.delegate as! AppDelegate
    var following : [FollowData] = []
    var posts : [Posts] = []
    var searchPost: [SearchData] = []
    var myPostData: [Posts] = []
    var repleDatas : [RepleData] = []
    var chatModel : [ChatModel] = []
    var myProfile: MyProfile?
    var followString : [String] = []
    var followPostCount: Int?
    func snapshotListenerCheckEvent(_ uid: String,
                                    _ badge: UIImageView,
                                    _ contents: [String]) {
        userRef
            .document(uid)
            .addSnapshotListener(includeMetadataChanges: true) { snapshot, error in
                if let error = error { print(error.localizedDescription) }
                
                guard let userData = snapshot?.data() else { return }
                let likeCheck = userData["like"] as? Bool ?? false
                let followCheck = userData["follow"] as? Bool ?? false
                let repleCheck = userData["reple"] as? Bool ?? false
                let chatCheck = userData["chatting"] as? Bool ?? false
                let postCheck = userData["newPost"] as? Bool ?? false
                
                for i in 0..<contents.count {
                    if contents[i] == "like" {
                        if likeCheck == true {
                            self.notificationControl(uid,
                                                     "좋아요",
                                                     "누군가 당신의 게시글에 좋아요를 눌렀습니다.",
                                                     "like",
                                                     badge,
                                                     "like-message")
                            
                        }
                    } else if contents[i] == "follow" {
                        if followCheck == true {
                            self.notificationControl(uid,
                                                     "팔로우",
                                                     "누군가 당신을 팔로우합니다.",
                                                     "follow",
                                                     badge,
                                                     "follow-message")
                        }
                    } else if contents[i] == "reple" {
                        if repleCheck == true {
                            self.notificationControl(uid,
                                                     "댓글",
                                                     "누군가 당신의 게시글에 댓글을 남겼습니다.",
                                                     "reple",
                                                     badge,
                                                     "reple-message")
                        }
                    } else if contents[i] == "chatting" {
                        if chatCheck == true {
                            self.notificationControl(uid,
                                                     "대화",
                                                     "누군가 당신에게 메세지를 보냈습니다.",
                                                     "chatting",
                                                     badge,
                                                     "chatting-message")
                        }
                    } else if contents[i] == "newPost" {
                        
                        if postCheck == true {
                            self.notificationControl(uid,
                                                     "새 글",
                                                     "팔로우 중 한명이 새로운 게시글을 올렸습니다.",
                                                     "newPost",
                                                     badge,
                                                     "newPost-message")
                        } else {
                            State.shread.checkNotificationCheck  = false
                        }
                    }
                }
        }
    }
    
    func notificationControl(_ uid: String,_ title:String, _ body: String, _ documentID: String, _ badge: UIImageView, _ categoryIdentifier: String) {
        let center = UNUserNotificationCenter.current()
        let content = UNMutableNotificationContent()
        content.body = "누군가 당신의 게시글에 좋아요를 눌렀습니다."
        content.badge = 1
        content.title = title
        content.sound = UNNotificationSound.default
        content.categoryIdentifier = categoryIdentifier
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 1, repeats: false)
        let requeset = UNNotificationRequest(identifier: documentID, content: content, trigger: trigger)
        center.add(requeset) { error in
            if let error = error { print("error : \(error)") }
            userRef.document(uid).updateData([documentID:false])
            State.shread.sideViewBadgeCheck = true
        }
        if documentID != "newPost" {
            DispatchQueue.main.async {
                badge.isHidden = false
            }
        }
    }
    
    func loadPostRepleDatas(uid: String,
                            postDate: String,
                            imageURL:[String],
                            completion : @escaping () -> Void)   {
        repleDatas.removeAll()
        postRef
            .order(by:"\(uid)")
            .getDocuments { [weak self] postList, error in
                guard let self = self else { return }
                guard let postList = postList?.documents else {return }
                for docment in postList {
                    guard let data = docment.data() as? [String:[String:Any]] else { return   }
                    for (_,i) in data {
                        guard let date = i["date"] as? String else { return }
                        guard let postImageURL = i["postImageURL"] as? [String] else { return  }
                        
                        if postDate == date, imageURL == postImageURL {
                            let repleURL = postRef.document(docment.documentID).collection("repleList")
                            repleURL
                                .getDocuments { snapshot, error in
                                    
                                    guard let snapshot = snapshot?.documents else { return  }
                                    for i in snapshot {
                                        guard let repleData = RepleData(document: i) else { return }
                                        self.repleDatas.append(repleData)
                                    }
                                    
                                    completion()
                            }
                        }
                    }
                }
        }
    }
    
    func fecthMyFollowPosting(completion : @escaping () -> Void) {
        guard let currentUID = CurrentUID.shread.currentUID else { return }
        following.removeAll()
        followString.removeAll()
        myPostData.removeAll()
        followRef
            .document("\(currentUID)")
            .collection("FollowList")
            .getDocuments { [weak self] followList, error in
                guard let self = self else { return }
                guard let followList = followList?.documents else { return }
                
                if followList.isEmpty {
                    print("empty")
                    completion()
                } else {
                    for userdoc in followList {
                        guard let user = FollowData(document: userdoc) else { continue }
                        self.following.append(user)
                        if followList.count == self.following.count {
                            self.fecthFollowPost {
                                completion()
                            }
                        }
                    }
                }
        }
    }
    
    func fecthFollowPost(completion : @escaping () -> Void) {
        guard let currentUID = CurrentUID.shread.currentUID else { return }

        if following.isEmpty {
            completion()
        } else {
            for i in 0..<following.count {
                postRef
                    .order(by: "\(following[i].userUID)")
                    .getDocuments { [weak self] list,error in
                        guard let self = self else { return }
                        guard let list = list?.documents else { return }
                        self.followPostCount = list.count
                        if list.isEmpty {
                            completion()
                        } else {
                            for document in list {
                                let dataID = document.documentID
                                let likeurl = Firestore.firestore().goodMark(dataID)
                                let viewurl = Firestore.firestore().viewCount(dataID)
                                
                                likeurl.document(currentUID).getDocument { likeCheck, error in
                                    likeurl.getDocuments { likeCount, error in
                                        viewurl.getDocuments { viewCheck, error in
                                            Posts.cleanData(list.count,
                                                            document.data() as? [String:[String:Any]],
                                                            dataID,
                                                            userRef,
                                                            viewurl,
                                                            likeurl,
                                                            currentUID,
                                                            likeCheck,
                                                            likeCount,
                                                            viewCheck) { data in
                                                                self.myPostData.append(data)
                                                                if self.myPostData.count == list.count {
                                                                    self.loadMyFeed {
                                                                        completion()
                                                                    }
                                                                }
                                            }
                                        }
                                    }
                                }
                            }
                        }
                }
            }
        }
    }
    
    //MARK:Firestore PostDataFetch Func
    func loadMyFeed(completion : @escaping () -> Void) {
        guard let currentUID = CurrentUID.shread.currentUID else { return }

        let count = followPostCount ?? 0
        postRef
            .order(by: "\(currentUID)")
            .getDocuments { [weak self] (querySnapshot, error) in
                guard let self = self else { return }
                guard let query = querySnapshot?.documents else { return }
                
                if query.isEmpty {
                    completion()
                } else {
                    for i in 0..<query.count {
                        let documentID = query[i].documentID
                        let snapshot = query[i].data() as? [String:[String:Any]]
                        let likeurl = Firestore.firestore().goodMark(documentID)
                        let viewurl = Firestore.firestore().viewCount(documentID)
                        
                        likeurl.document(documentID).getDocument { myCheck,error  in
                            likeurl.getDocuments { likeCheck, error  in
                                viewurl.getDocuments { viewCheck, error in
                                    viewurl.document(currentUID).setData([currentUID:true])
                                    Posts.cleanData(query.count,
                                                    snapshot,
                                                    documentID,
                                                    userRef,
                                                    viewurl,
                                                    likeurl,
                                                    currentUID,
                                                    myCheck,
                                                    likeCheck,
                                                    viewCheck) { data in
                                                        self.myPostData.append(data)
                                                        if self.myPostData.count == query.count + count {
                                                            self.loadProfile {
                                                                completion()
                                                            }
                                                            
                                                        }
                                    }
                                }
                            }
                        }
                    }
                }
        }
    }
    
    //MARK: SearchViewController Loading Post func
    func loadSearchFeedPost(completion : @escaping () -> Void) {
        guard let currentUID = CurrentUID.shread.currentUID else { return }

        posts.removeAll()
        postRef
            .getDocuments { [weak self] querySnapshot, error in
                guard let self = self else { return }
                guard let snapshot = querySnapshot?.documents else { return }
                
                if let error = error { print("\(error.localizedDescription)")
                } else {
                    if snapshot.isEmpty {
                        completion()
                    } else {
                        for document in snapshot {
                            let docID = document.documentID
                            guard let data = document.data() as? [String:[String:Any]] else { return }
                            let likeurl = Firestore.firestore().goodMark(docID)
                            let viewurl = Firestore.firestore().viewCount(docID)
                            likeurl.document(currentUID).getDocument { searchLikeMark, error in
                                likeurl.getDocuments { likeCount, error in
                                    viewurl.getDocuments { viewCheck, error in
                                        Posts.cleanData(snapshot.count,
                                                        data,
                                                        docID,
                                                        userRef,
                                                        viewurl,
                                                        likeurl,
                                                        currentUID,
                                                        searchLikeMark,
                                                        likeCount,
                                                        viewCheck) { data in
                                                            self.posts.append(data)
                                                            if self.posts.count == snapshot.count {
                                                           
                                                                completion()
                                                            }
                                        }
                                    }
                                }
                            }
                        }
                    }
                }
        }
    }
    
    func loadProfile(completion : @escaping () -> Void) {
        guard let currentUID = CurrentUID.shread.currentUID else { return }

        myProfile = nil
        
        userRef
            .document("\(currentUID)")
            .getDocument() { [weak self] snapshot,error in
                guard let self = self else { return  }
                if let error = error {
                    print("\(error.localizedDescription)")
                } else {
                    guard let snapshot = snapshot,
                        let myProfileData = MyProfile(document: snapshot) else { return }
                    self.myProfile = myProfileData
                    completion()
                }
        }
    }
    
    func getChatRoomLists(completion : @escaping () -> Void) {
        guard let currentUID = CurrentUID.shread.currentUID else { return }

        if currentUID.isEmpty {
            return
        } else {
            chatRoomRef
                .queryOrdered(byChild: "users/"+currentUID)
                .queryEqual(toValue: true)
                .observeSingleEvent(of: .value) { snapshot in
                    
                    self.chatModel.removeAll()
                    guard let snapshot = snapshot.children.allObjects as? [DataSnapshot] else { return }
                    for id in snapshot {
                        
                        if let chatRoomdic = id.value as? [String:AnyObject] {
                            guard let chatModel = ChatModel(JSON: chatRoomdic) else { return }
                            self.chatModel.append(chatModel)
                            
                            if snapshot.count == self.chatModel.count {
                                completion()
                            }
                        }
                    }
            }
        }
    }
    
}
