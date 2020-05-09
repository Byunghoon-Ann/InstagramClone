//
//  CurrentUID.swift
//  MakeFairytale
//
//  Created by ByungHoon Ann on 2020/04/25.
//  Copyright © 2020 ByungHoon Ann. All rights reserved.
//

import Foundation
import Firebase

final class CurrentUID {
    static let shread = CurrentUID()
    var yourUID = ""
    var profileURL: String?
    var nickName: String?
    var usingAgree = false
    var currentUID: String? {
        willSet{
            guard let currentUID = Auth.auth().currentUser?.uid else { return }
            self.currentUID = currentUID
        }
    }
    
    private init() { }
}
