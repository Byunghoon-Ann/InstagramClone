//
//  MyProfile.swift
//  MakeFairytale
//
//  Created by ByungHoon Ann on 2020/01/31.
//  Copyright © 2020 ByungHoon Ann. All rights reserved.
//

import UIKit
import Firebase

struct MyProfile  {
    var profileImageURL:String
    var email:String
    var nickName:String
    var uid:String
}

extension MyProfile: DocumentSerializable {
    var documentID: String  {
        return uid
    }
    
    private init?(documentID:String, dictionary: [String:Any]) {
        guard let userID = dictionary["uid"] as? String else { return nil }
        precondition( userID == documentID )
        self.init(dictionary: dictionary)
    }
    
    private init?(dictionary:[String:Any]) {
        guard let uid = dictionary["uid"] as? String,
            let profileURL = dictionary["profileImageURL"] as? String,
            let nickName = dictionary["nickName"] as? String,
            let email = dictionary["email"] as? String else { return nil }
        self.init(uid: uid, nickName: nickName, email: email, profileURL: profileURL)
    }
    
    public init?(document: QueryDocumentSnapshot) {
        self.init(documentID: document.documentID, dictionary: document.data())
    }
    
    public init?(document: DocumentSnapshot) {
        guard let data = document.data() else { return nil }
        self.init(documentID: document.documentID, dictionary: data)
    }
    
    private init?(uid: String, nickName: String, email:String, profileURL:String) {
        self.init(profileImageURL: profileURL, email: email, nickName: nickName, uid: uid)
    }
    
    public var documentData: [String : Any] {
        return [
            "uid": uid,
            "nickName":nickName,
            "profileImageURL":profileImageURL,
            "email":email
        ]
    }
    
}
