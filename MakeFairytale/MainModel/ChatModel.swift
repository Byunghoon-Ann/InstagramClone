//
//  ChatModel.swift
//  MakeFairytale
//
//  Created by ByungHoon Ann on 2020/02/13.
//  Copyright © 2020 ByungHoon Ann. All rights reserved.
//

import UIKit
import ObjectMapper
class ChatModel : Mappable {
    var users: Dictionary<String,Bool> = [:] // 챗에 참여한 사람들
    var comments: Dictionary<String,Comment> = [:] //챗의 대화내용
    var timeStamp: Int?
    
    required init?(map: Map) {}
    
    func mapping(map: Map) {
        users <- map["users"]
        comments <- map["comments"]
        timeStamp <- map["timeStamp"]
    }
    
    class Comment : Mappable {
        var uid: String?
        var message: String?
        var timeStamp: Int?
        var readUsers: Dictionary<String,Bool> = [:]
        required init?(map: Map) {
            
        }
        
        func mapping(map: Map) {
            uid <- map["uid"]
            message <- map["message"]
            timeStamp <- map["timeStamp"]
            readUsers <- map["readUsers"]
        }
        
    }
}
