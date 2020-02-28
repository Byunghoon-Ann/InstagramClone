//
//  LoadFile.swift
//  MakeFairytale
//
//  Created by ByungHoon Ann on 12/10/2019.
//  Copyright © 2019 ByungHoon Ann. All rights reserved.
//
//MARK:- 팔로우, 포스트, 전체포스트(서치뷰용) 리스트 로드 함수 파일
import Foundation
import Firebase

fileprivate let firestoreRef = Firestore.firestore()

class LoadFile {
    
    static var shread : LoadFile = LoadFile()
    
    private init() {}
    
    let appDelegate = UIApplication.shared.delegate as! AppDelegate
    var following : [FollowData] = []
    var posts : [Posts] = []
    var searchPost: [SearchData] = []
    var myData : [MyData] = []
    var myPostData: [Posts] = []
    var repleDatas : [RepleData] = []
    var chatModel : [ChatModel] = []
    var followString : [String] = []
    
    func snapshotListenerCheckEvent(_ uid: String,
                                    _ badge: UIImageView,
                                    _ contents: [String]) {
        
        firestoreRef
            .collection("user")
            .document(uid)
            .addSnapshotListener(includeMetadataChanges: true) { snapshot, error in
                if let error = error { print(error.localizedDescription)}
            
                guard let snapshot = snapshot else {return}
                guard let userData = snapshot.data() else {return }
                let likeCheck = userData["like"] as? Bool ?? false
                let followCheck = userData["follow"] as? Bool ?? false
                let repleCheck = userData["reple"] as? Bool ?? false
                let chatCheck = userData["chatting"] as? Bool ?? false
                let postCheck = userData["newPost"] as? Bool ?? false
                for i in 0..<contents.count {
                    if contents[i] == "like" || contents[i] == "follow" || contents[i] == "reple" {
                        if likeCheck == true || followCheck == true || repleCheck == true {
                            badge.isHidden = false
                        } else {
                            badge.isHidden = true
                        }
                    } else if contents[i] == "chatting" {
                        if chatCheck == true {
                            badge.isHidden = false
                        }else {
                            badge.isHidden = true
                        }
                    } else if contents[i] == "newPost" {
                        if postCheck == true {
                            self.appDelegate.checkNotificationCheck  = true
                        } else {
                            self.appDelegate.checkNotificationCheck  = false
                        }
                    }
                }
        }
    }
    
    func loadPostRepleDatas(uid: String,
                            postDate: String,
                            imageURL:[String],
                            completion : @escaping () -> Void)   {
        repleDatas.removeAll()
        firestoreRef
            .collection("AllPost")
            .order(by:"\(uid)")
            .getDocuments { postList, error in
                guard let postList = postList?.documents else {return }
                for docment in postList {
                    guard let data = docment.data() as? [String:[String:Any]] else { return   }
                    for (_,i) in data {
                        guard let date = i["date"] as? String else { return }
                        guard let postImageURL = i["postImageURL"] as? [String] else { return  }
                        
                        if postDate == date, imageURL == postImageURL {
                            let docKey = docment.documentID
                            
                            firestoreRef
                                .collection("AllPost")
                                .document(docKey)
                                .collection("repleList")
                                .addSnapshotListener { snapshot, error in
                                    
                                    guard let snapshot = snapshot?.documents else { return  }
                                    
                                    for i in snapshot {
                                        let repleData = i.data()
                                        let profile = repleData["profileImageURL"] as? String ?? ""
                                        let uid = repleData["uid"] as? String ?? ""
                                        let reple = repleData["reple"] as? String ?? ""
                                        let nickName = repleData["nickName"] as? String ?? ""
                                        let repleDate = repleData["repleDate"] as? String ?? ""
                                        self.repleDatas.append(RepleData(uid: uid,
                                                                         userThumbnail: profile,
                                                                         userReple: reple,
                                                                         nickName:nickName,
                                                                         repleDate:repleDate))
                                    }
                                    completion()
                            }
                        }
                    }
                }
        }
    }
    
    func fecthMyFollowPosting(completion : @escaping () -> Void) {
        following.removeAll()
        followString.removeAll()
        myPostData.removeAll()
        guard let currentUID = appDelegate.currentUID else { return }
        firestoreRef
            .collection("Follow")
            .document("\(currentUID)")
            .collection("FollowList")
            .getDocuments { followList, error in
                guard let followList = followList?.documents else { return }
                
                if followList.isEmpty {
                    completion()
                } else {
                    for i in followList {
                        let data = i.data()
                        
                        let uid = data["uid"] as? String ?? ""
                        firestoreRef
                            .collection("user")
                            .document(uid)
                            .getDocument { userData, _ in
                                guard let userData = userData?.data() else { return }
                                let profile = userData["profileImageURL"] as? String ?? ""
                                let nickName = userData["nickName"] as? String ?? ""
                                
                                self.followString.append(uid)
                                self.following.append(FollowData(userName: nickName,
                                                                 userThumbnail: profile,
                                                                 userUID: uid))
                           
                                if followList.count == self.following.count {
                                    completion()
                                }
                        }
                    }
                }
        }
    }
    
    func fecthFollowPost(completion : @escaping () -> Void) {
        guard let currentUID = appDelegate.currentUID else { return }
        let databaseRef = firestoreRef.collection("AllPost")
        if followString.isEmpty {
            completion()
        } else {
            for i in followString {
                databaseRef
                    .order(by: "\(i)")
                    .getDocuments { list,error in
                        guard let list = list?.documents else { return }
                        if list.isEmpty {
                            completion()
                        } else {
                            for document in list {
                                guard let data = document.data() as? [String:[String:Any]] else { return }
                                let dataID = document.documentID
                                firestoreRef
                                    .collection("AllPost")
                                    .document(dataID)
                                    .collection("goodMarkLog")
                                    .document(currentUID)
                                    .getDocument { likeCheck, error in
                                        
                                        firestoreRef
                                            .collection("AllPost")
                                            .document(dataID)
                                            .collection("goodMarkLog")
                                            .getDocuments { likeCount, error in
                                                
                                                firestoreRef
                                                    .collection("AllPost")
                                                    .document(dataID)
                                                    .collection("ViewCheck")
                                                    .getDocuments { viewCheck, error in
                                                        for (_,j) in data {
                                                            var viewCount = 0
                                                            var likeCounts = 0
                                                            var like = false
                                                            let postComment = j["postComment"] as? String ?? ""
                                                            let postImageURL = j["postImageURL"] as? [String] ?? [""]
                                                            let date = j["date"] as? String ?? ""
                                                            let uid = j["uid"] as? String ?? ""
                                                            
                                                            if let likeCheck = likeCheck?.data() {
                                                                like = likeCheck["like"] as? Bool ?? false
                                                            }
                                                            if let likeCount = likeCount?.documents {
                                                                for check in likeCount {
                                                                    let like = check["like"] as? Bool ?? false
                                                                    if like == true {
                                                                       likeCounts += 1
                                                                    }
                                                                }
                                                            }
                                                            
                                                            if let viewCheck = viewCheck {
                                                                viewCount = viewCheck.count
                                                            }
                                                            
                                                            firestoreRef
                                                                .collection("user")
                                                                .document(uid)
                                                                .getDocument { userData, _ in
                                                                    guard let userData = userData?.data() else { return }
                                                                    let name = userData["nickName"] as? String ?? ""
                                                                    let thumbnail = userData["profileImageURL"] as? String ?? ""
                                                                    self.myPostData
                                                                        .append(Posts(userUID: uid,
                                                                                      userName: name,
                                                                                      userComment: postComment,
                                                                                      userProfileImage: thumbnail,
                                                                                      userPostImage: postImageURL,
                                                                                      postDate: date,
                                                                                      goodMark: like,
                                                                                      viewCount: viewCount,
                                                                                      likeCount: likeCounts,
                                                                                      urlkey:dataID))
                                                                    
                                                                    firestoreRef
                                                                        .collection("AllPost")
                                                                        .document(dataID)
                                                                        .collection("ViewCheck")
                                                                        .document(currentUID)
                                                                        .setData([currentUID:true])
                                                                    
                                                                    if self.myPostData.count == list.count {
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
        guard let currentUID = appDelegate.currentUID else { return }
        self.appDelegate.myPost.removeAll()
        firestoreRef
            .collection("AllPost")
            .order(by: "\(currentUID)")
            .getDocuments { (querySnapshot, error) in
                guard let query = querySnapshot?.documents else { return }
                if query.isEmpty {
                    completion()
                } else {
                    var datas : [Posts] = []
                    for document in query {
                        guard let data = document.data() as? [String:[String:Any]] else { return }
                        let dataID = document.documentID
                        firestoreRef
                            .collection("AllPost")
                            .document(dataID)
                            .collection("goodMarkLog")
                            .document(currentUID)
                            .getDocument { myCheck, error in
                                
                                firestoreRef
                                    .collection("AllPost")
                                    .document(dataID)
                                    .collection("goodMarkLog")
                                    .getDocuments { likeCheck,error  in
                                        
                                        firestoreRef.collection("AllPost")
                                            .document(dataID)
                                            .collection("ViewCheck")
                                            .getDocuments { viewCheck, error in
                                                
                                                for (_,j) in data {
                                                    var viewCount = 0
                                                    var likeCount = 0
                                                    var like = false
                                                    let uid = j["uid"] as? String ?? ""
                                                    let postComment = j["postComment"] as? String ?? ""
                                                    let postImageURL = j["postImageURL"] as? [String] ?? [""]
                                                    let date = j["date"] as? String ?? ""
                                                    
                                                    if let viewCheck = viewCheck {
                                                        viewCount = viewCheck.count
                                                    }
                                                    
                                                    if let likeCheck = likeCheck?.documents {
                                                        for check in likeCheck {
                                                            let like = check["like"] as? Bool ?? false
                                                            if like == true {
                                                                likeCount += 1
                                                            }
                                                        }
                                                    }
                                                    
                                                    if let myCheck = myCheck?.data() {
                                                        like = myCheck["like"] as? Bool ?? false
                                                        
                                                    } else {
                                                        firestoreRef
                                                            .collection("AllPost")
                                                            .document(dataID)
                                                            .collection("goodMarkLog")
                                                            .document(currentUID)
                                                            .setData(["like":false])
                                                        like = false
                                                    }
                                                    
                                                    firestoreRef
                                                        .collection("user")
                                                        .document(uid)
                                                        .getDocument { userData, _ in
                                                            guard let userData = userData?.data() else { return }
                                                            let name = userData["nickName"] as? String ?? ""
                                                            let thumbnail = userData["profileImageURL"] as? String ?? ""
                                                            
                                                            datas.append(Posts(userUID: uid,
                                                                               userName: name,
                                                                               userComment: postComment,
                                                                               userProfileImage: thumbnail,
                                                                               userPostImage: postImageURL,
                                                                               postDate: date,
                                                                               goodMark: like,
                                                                               viewCount: viewCount,
                                                                               likeCount: likeCount,
                                                                               urlkey: dataID))
                                                            if datas.count == query.count {
                                                                self.myPostData += datas
                                                                self.appDelegate.myPost += datas
                                                                completion()
                                                            }
                                                            firestoreRef
                                                                .collection("AllPost")
                                                                .document(dataID)
                                                                .collection("ViewCheck")
                                                                .document(currentUID)
                                                                .setData([currentUID:true])
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
        posts.removeAll()
        guard let currentUID = appDelegate.currentUID else { return }
        
        firestoreRef
            .collection("AllPost")
            .getDocuments { querySnapshot, error in
                
                guard let snapshot = querySnapshot?.documents else { return }
                
                if let error = error { print("\(error.localizedDescription)")
                    
                } else {
                    if snapshot.isEmpty {
                        completion()
                    } else {
                        var datas = [Posts]()
                        
                        for document in snapshot {
                            let docID = document.documentID
                            guard let data = document.data() as? [String:[String:Any]] else { return }
                            
                            firestoreRef
                                .collection("AllPost")
                                .document(docID)
                                .collection("goodMarkLog")
                                .document(currentUID)
                                .getDocument { searchLikeMark, error in
                                    
                                    firestoreRef
                                        .collection("AllPost")
                                        .document(docID)
                                        .collection("goodMarkLog")
                                        .getDocuments { likeCount, error in
                                            
                                            firestoreRef
                                                .collection("AllPost")
                                                .document(docID)
                                                .collection("ViewCheck")
                                                .getDocuments { viewCheck, error in
                                                    
                                                    for (_,j) in data {
                                                        
                                                        var viewCount = 0
                                                        var likeCounts = 0
                                                       
                                                        let postComment = j["postComment"] as? String ?? ""
                                                        let postImageURL = j["postImageURL"] as? [String] ?? [""]
                                                        let date = j["date"] as? String ?? ""
                                                
                                                        let uid = j["uid"] as? String ?? ""
                                                        var like = false
                                                        
                                                        if let likeCheck = searchLikeMark?.data() {
                                                            let likes = likeCheck["like"] as? Bool ?? false
                                                            like = likes
                                                        }
                                                        
                                                        if let viewCheck = viewCheck {
                                                            viewCount = viewCheck.count
                                                        }
                                                        
                                                        if let likeCount = likeCount?.documents {
                                                            for check in likeCount {
                                                                let like = check["like"] as? Bool ?? false
                                                                if like == true {
                                                                    likeCounts += 1
                                                                }
                                                            }
                                                        }
                                                        
                                                        firestoreRef
                                                        .collection("user")
                                                        .document(uid)
                                                        .getDocument { userData, _ in
                                                            guard let userData = userData?.data() else { return }
                                                            let name = userData["nickName"] as? String ?? ""
                                                            let thumbnail = userData["profileImageURL"] as? String ?? ""
                                                            
                                                        datas.append(Posts(userUID: uid,
                                                                           userName: name,
                                                                           userComment: postComment,
                                                                           userProfileImage: thumbnail,
                                                                           userPostImage: postImageURL,
                                                                           postDate: date,
                                                                           goodMark: like,
                                                                           viewCount: viewCount,
                                                                           likeCount: likeCounts,
                                                                           urlkey:docID))
                                                            
                                                            firestoreRef
                                                                .collection("AllPost")
                                                                .document(docID)
                                                                .collection("ViewCheck")
                                                                .document(currentUID)
                                                                .setData([currentUID:true])
                                                            
                                                            if snapshot.count == datas.count {
                                                                self.posts += datas
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
    
    func getChatRoomLists(completion : @escaping () -> Void) {
        let currentUID = appDelegate.currentUID ?? ""
        if currentUID.isEmpty {
            return
        } else {
            Database.database()
                .reference()
                .child("chatRooms")
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
