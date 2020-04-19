//
//  UITableViewExtension.swift
//  MakeFairytale
//
//  Created by ByungHoon Ann on 2020/04/19.
//  Copyright © 2020 ByungHoon Ann. All rights reserved.
//

import UIKit
extension UITableView {
    func registerCell<T: UITableViewCell>(_: T.Type) {
        if let nib = T.nib {
            self.register(nib, forCellReuseIdentifier: T.reuseIdentifier)
        } else {
            self.register(T.self, forCellReuseIdentifier: T.reuseIdentifier)
        }
    }
    
    func dequeueCell<T: UITableViewCell>(indexPath: IndexPath) -> T {
        return self.dequeueReusableCell(withIdentifier: T.reuseIdentifier, for: indexPath) as! T
    }
    
}
