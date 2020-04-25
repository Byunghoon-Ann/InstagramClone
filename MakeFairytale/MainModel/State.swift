//
//  CheckInterface.swift
//  MakeFairytale
//
//  Created by ByungHoon Ann on 2020/04/25.
//  Copyright © 2020 ByungHoon Ann. All rights reserved.
//

import Foundation

final class State {
    static let shread = State()
    
    var autoRefreshingCheck = false
    var sideViewBadgeCheck = false
    var chattingCheck = false
    var checkNotificationCheck = false
    
    private init() {}
}
