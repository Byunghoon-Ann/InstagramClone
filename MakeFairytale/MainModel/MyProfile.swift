//
//  MyProfile.swift
//  MakeFairytale
//
//  Created by ByungHoon Ann on 2020/01/31.
//  Copyright © 2020 ByungHoon Ann. All rights reserved.
//

import UIKit

struct MyProfile  {
    var profileImageURL: String
    var email: String
    var nickName: String
    var uid :String
    
    init(profileImageURL: String, email: String, nickName: String, uid: String) {
        self.profileImageURL = profileImageURL
        self.email = email
        self.nickName = nickName
        self.uid = uid
    }
}
