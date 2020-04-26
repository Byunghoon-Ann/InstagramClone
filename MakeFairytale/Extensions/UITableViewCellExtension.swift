//
//  ExtensionTableViewCell.swift
//  MakeFairytale
//
//  Created by ByungHoon Ann on 2020/02/14.
//  Copyright © 2020 ByungHoon Ann. All rights reserved.
//

import UIKit
extension UITableViewCell: Reusable { }

extension UITableViewCell {
    func actionControlOption(_ festaData: Posts,
                             _ pageControl: UIPageControl) {
        pageControl.numberOfPages = festaData.userPostImage.count
        if festaData.userPostImage.count == 1 {
            pageControl.isHidden = true
        }else {
            pageControl.isHidden = false
        }
    }
}
