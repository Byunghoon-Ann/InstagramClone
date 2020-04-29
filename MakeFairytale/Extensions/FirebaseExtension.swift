//
//  FirebaseExtension.swift
//  MakeFairytale
//
//  Created by ByungHoon Ann on 2020/04/17.
//  Copyright © 2020 ByungHoon Ann. All rights reserved.
//

import Firebase
import UIKit

extension Firestore {
    var user: CollectionReference {
      return self.collection("user")
    }

    /// Returns a reference to the top-level restaurants collection.
    var posts: CollectionReference {
      return self.collection("AllPost")
    }

    /// Returns a reference to the top-level reviews collection.
    var follow: CollectionReference {
      return self.collection("Follow")
    }

    var follower: CollectionReference {
        return self.collection("Follower")
    }
    
    
    func goodMark(_ documentID: String) -> CollectionReference  {
        return self.collection("AllPost").document(documentID).collection("goodMarkLog")
    }
    
    func viewCount(_ documentID:String) -> CollectionReference {
        return posts.document(documentID).collection("ViewCheck")
    }
    
    func followingRef(_ documentID : String) -> CollectionReference {
        return follow.document(documentID).collection("FollowList")
    }
    
    func followerRef(_ documentID: String) -> CollectionReference {
        return follower.document(documentID).collection("FollowerList")
    }
    
    //MARK:- 알림 감지용 contents를 분별하기 위한 함수
    func alertContentsCenter(_ alertContent: String, _ yourUid: String) {
        switch alertContent {
        case "like":
            user.document(yourUid).updateData(["like":true])
        case "chatting":
            user.document(yourUid).updateData(["chatting":true])
        case "follow":
            user.document(yourUid).updateData(["follow":true])
        case "post":
            user.document(yourUid).updateData(["newPost":true])
        case "reple":
            user.document(yourUid).updateData(["reple":true])
        default :
            print("error!")
        }
    }
    
    static func getOtherRef(_ collection: String, _ documentID: String) -> DocumentReference {
        return Firestore.firestore().collection(collection).document(documentID)
    }
}


