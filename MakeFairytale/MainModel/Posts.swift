//
//  Posts.swift
//  MakeFairytale
//
//  Created by ByungHoon Ann on 2020/01/31.
//  Copyright © 2020 ByungHoon Ann. All rights reserved.
//

import Firebase

struct  Posts  {
    var userUID: String
    var userName: String
    var userComment: String
    var userProfileImage: String
    var userPostImage: [String]
    var postDate: String
    var goodMark: Bool
    var viewCount: Int
    var likeCount: Int
    var urlkey: String
}


extension Posts {
    static func cleanData(_ query:Int,
                          _ data:[String:[String:Any]]? ,
                          _ dataID:String,
                          _ userRef:CollectionReference,
                          _ viewurl:CollectionReference,
                          _ likeurl:CollectionReference,
                          _ currentUID:String,
                          _ myCheck: DocumentSnapshot?,
                          _ likeCheck: QuerySnapshot?,
                          _ viewCheck: QuerySnapshot?,completion: @escaping(Posts) -> Void) {
        
        if let data = data {
            
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
                    viewurl
                        .document(currentUID)
                        .setData(["like":false])
                    like = false
                }
                
                userRef
                    .document(uid)
                    .getDocument { userData, _ in
                        guard let userData = userData?.data() else { return }
                        let name = userData["nickName"] as? String ?? ""
                        let thumbnail = userData["profileImageURL"] as? String ?? ""
                        completion(Posts(userUID: uid,
                                     userName: name,
                                     userComment: postComment,
                                     userProfileImage: thumbnail,
                                     userPostImage: postImageURL,
                                     postDate: date,
                                     goodMark: like,
                                     viewCount: viewCount,
                                     likeCount: likeCount,
                                     urlkey: dataID))
                }
            }
        }
    }
    
    static func postDateSort(_ post: inout [Posts],
                             _ today: Date,
                             _ dateFomatter:DateFormatter) -> [Posts]{
        post.sort { firstItem, secondItem in
            let firstDate = dateFomatter.date(from: firstItem.postDate) ?? today
            let secondDate = dateFomatter.date(from: secondItem.postDate) ?? today
            
            if  firstDate > secondDate {
                return true
            } else {
                return false
            }
        }
        return post
    }
}

