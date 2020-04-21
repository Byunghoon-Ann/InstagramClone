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
}


