//
//  CommenService.swift
//  MakeFairytale
//
//  Created by ByungHoon Ann on 2020/04/24.
//  Copyright © 2020 ByungHoon Ann. All rights reserved.
//

import UIKit

enum SelectedType: String {
    case option = "안내"
    case logout = "로그아웃"
    case block = "차단"
    case report = "신고"
}

 class CommonService {
    static let shread = CommonService()
    
    var orderSelect: SelectedType = .option
}
