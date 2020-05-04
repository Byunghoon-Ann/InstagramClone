//
//  MyFestaStoryPageCell.swift
//  MakeFairytale
//
//  Created by ByungHoon Ann on 2020/02/12.
//  Copyright © 2020 ByungHoon Ann. All rights reserved.
//

import UIKit
//MARK: pageCollectionView의 셀
class MyFestaStoryPageCell : UICollectionViewCell {
    lazy var label: UILabel = {
        let label = UILabel()
        label.textColor = .black
        label.textAlignment = .center
        label.font = .boldSystemFont(ofSize: 15)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    override func awakeFromNib() {
        super.awakeFromNib()
        addSubview(label)
        self.backgroundColor = .white
        label.centerXAnchor.constraint(equalTo: self.centerXAnchor).isActive = true
        label.centerYAnchor.constraint(equalTo: self.centerYAnchor).isActive = true
    }
    
}
