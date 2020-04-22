//
//  RepleData.swift
//  MakeFairytale
//
//  Created by ByungHoon Ann on 2020/01/31.
//  Copyright © 2020 ByungHoon Ann. All rights reserved.
//

import UIKit
import Firebase

struct RepleData {
    var uid: String
    var userThumbnail: String
    var userReple: String
    var nickName: String
    var repleDate: String
}

extension RepleData: DocumentSerializable {
    var documentID: String {
        return uid
    }
    
    private init?(documentID:String, dictionary:[String:Any]) {
        self.init(dictionary: dictionary)
    }
    
    private init?(dictionary:[String:Any]) {
        let profileURL = dictionary["profileImageURL"] as? String ?? ""
        guard let uid = dictionary["uid"] as? String,
        let nickName = dictionary["nickName"] as? String,
        let repleDate = dictionary["repleDate"] as? String,
        let reple = dictionary["reple"] as? String else { return nil }
        self.init(uid: uid, userThumbnail: profileURL, userReple: reple, nickName: nickName, repleDate: repleDate)
    }
    
    public init?(document: QueryDocumentSnapshot) {
        self.init(documentID: document.documentID, dictionary: document.data() )
    }
    
    public init?(document: DocumentSnapshot) {
        guard let data = document.data() else { return nil }
        self.init(documentID: document.documentID, dictionary: data)
    }
    
    public var documentData: [String : Any] {
        return [
            "uid":uid,
            "profileImageURL":userThumbnail,
            "reple":userReple,
            "repleDate":repleDate,
            "nickName":nickName
        ]
    }
}
