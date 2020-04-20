//
//  UIStroyboardExtension.swift
//  MakeFairytale
//
//  Created by ByungHoon Ann on 2020/04/20.
//  Copyright © 2020 ByungHoon Ann. All rights reserved.
//

import Foundation
import UIKit
extension UIStoryboard {
    static func instantiate<T:UIViewController>(by storyboardName: UIStoryboard.Storyboard) -> T? {
        let type = String(describing: T.Type.self)
        guard let identifier = type.components(separatedBy: ".").first else { return nil }
        
        let storyboard = UIStoryboard(name: storyboardName.rawValue, bundle: nil)
        let vc = storyboard.instantiateViewController(withIdentifier: identifier)
        
        return vc as? T
    }
}

extension UIStoryboard {
    enum  Storyboard: String {
        case main = "Main"
    }
    
    static func viewPostingVC() -> ViewPostingController? {
        return UIStoryboard.instantiate(by: .main)
    }
    
    static func plusCommentVC() -> PlusCommentViewContrller? {
        return UIStoryboard.instantiate(by: .main)
    }
    
    static func myFestaStoryVC() -> MyFestaStoryViewController? {
        return UIStoryboard.instantiate(by: .main)
    }
    
    static func notificationAlertVC() -> NotificationAlertViewController? {
        return UIStoryboard.instantiate(by: .main)
    }
    
    static func myStoryVC() -> MyStoryViewController? {
        return UIStoryboard.instantiate(by: .main)
    }
    
    static func loginVC() -> LoginViewController? {
        return UIStoryboard.instantiate(by: .main)
    }
    
    static func newSignInVC() -> NewSignInViewController? {
        return UIStoryboard.instantiate(by: .main)
    }
    
    static func chattingRoomVC() -> ChattingRoomViewController? {
        return UIStoryboard.instantiate(by: .main)
    }
}
