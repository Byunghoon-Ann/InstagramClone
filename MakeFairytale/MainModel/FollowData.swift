//
//  FollowData.swift
//  MakeFairytale
//
//  Created by ByungHoon Ann on 2020/01/31.
//  Copyright © 2020 ByungHoon Ann. All rights reserved.
//

import UIKit
import Firebase
struct FollowData {
    var userName: String
    var userThumbnail: String
    var userUID: String
    var date: String
}

extension FollowData: DocumentSerializable {
    var documentID: String {
        return userUID
    }
    
    private init?(documentID: String, dictionary: [String : Any]) {
        guard let userID = dictionary["uid"] as? String else { return nil }
        precondition(userID == documentID)
        self.init(dictionary: dictionary)
    }
    
    private init?( dictionary: [String:Any]) {
        guard let followID = dictionary["uid"] as? String,
            let profileURL = dictionary["profileImageURL"] as? String,
            let followName = dictionary["nickName"] as? String,
            let date = dictionary["date"] as? String else {return nil }
        self.init(userName:followName,userThumbnail:profileURL,userUID:followID,date:date)
        
    }
    
    public init?(document: QueryDocumentSnapshot) {
        self.init(documentID: document.documentID, dictionary:document.data())
    }
    
    public init?(document: DocumentSnapshot) {
        guard let data = document.data() else { return nil }
        self.init(documentID: document.documentID, dictionary: data)
    }
    
    public init(userUID:String, userName:String,userThumbnail:String,date:String) {
        self.init(userName: userName, userThumbnail: userThumbnail, userUID:  userUID,date:date)
    }
    
    
    public var documentData: [String : Any] {
        return [
            "uid":userUID,
            "nickName": userName,
            "profileImageURL": userThumbnail,
            "date":date
        ]
    }
}
