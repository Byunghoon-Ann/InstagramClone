//
//  Posts.swift
//  MakeFairytale
//
//  Created by ByungHoon Ann on 2020/01/31.
//  Copyright © 2020 ByungHoon Ann. All rights reserved.
//

import UIKit

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

/*
var documentID: String
    func pasing(data:[String:[String:Any]]) -> Posts {
        for (_,j) in data {
            let name = j["nake"] as? String ?? ""
        }
       let p = Posts(userUID: <#T##String#>, userName: <#T##String#>, userComment: <#T##String#>, userProfileImage: <#T##String#>, userPostImage: <#T##[String]#>, postDate: <#T##String#>, goodMark: <#T##Bool#>, viewCount: <#T##Int#>, likeCount: <#T##Int#>, urlkey: <#T##String#>)
        return p
    }


extension Posts: DocumentSerializable {

    init(userUID: String,
         userName: String,
         userComment: String,
         userProfileImage: String,
         userPostImage: [String],
         postDate: String,
         goodMark: Bool,
         viewCount: Int,
         likeCount: Int,
         urlKey:String) {
        let document = Firestore.firestore().posts.document()
        self.init(documentID:document.documentID,
                  userUID: userUID,
                  userName:userName,
                  userComment: userComment,
                  userProfileImage: userProfileImage,
                  userPostImage: userPostImage,
                  postDate: postDate, goodMark: goodMark,
                  viewCount: viewCount, likeCount: likeCount,
                  urlkey: urlKey)
    }

    private init?(documentID: String, dictionary:[String:Any]) {
        guard let userUID = dictionary[""] as? String,
            let userName = dictionary [""] as? String,
            let userComment = dictionary[""] as? String,
            let userProfileImage = dictionary[""] as? String,
            let postDate = dictionary[""] as? String,
            let goodMark = dictionary[""] as? Bool,
            let viewCount =  dictionary[""] as? Int,
            let likeCount = dictionary[""] as? Int,
            let userPostImage = dictionary[""] as? [String],
            let urlKey = dictionary[""] as? String  else { return nil }

        self.init(userUID: userUID,
                  userName: userName,
                  userComment: userComment,
                  userProfileImage: userProfileImage,
                  userPostImage: userPostImage,
                  postDate: postDate,
                  goodMark: goodMark,
                  viewCount: viewCount,
                  likeCount: likeCount,
                  urlKey: urlKey)

    }

    init?(document: QueryDocumentSnapshot) {
        self.init(documentID: document.documentID,dictionary: document.data() )
    }

    init?(document: DocumentSnapshot) {
        guard let data = document.data() else { return nil }
        self.init(documentID: document.documentID, dictionary: data)
    }



    var documentData: [String : Any] {
        return [
            "": userUID,
            "": userName,
            "": userComment,
            "": userProfileImage,
            "": userPostImage,
            "": postDate,
            "": goodMark,
            "":viewCount,
            "":likeCount,
            "":urlkey
        ]
    }


}
 */
