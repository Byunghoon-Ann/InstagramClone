//
//  ChattingListViewCell.swift
//  MakeFairytale
//
//  Created by ByungHoon Ann on 2020/02/13.
//  Copyright © 2020 ByungHoon Ann. All rights reserved.
//

import UIKit

class ChattingListViewCell : UITableViewCell {
    var imageview = UIImageView()
    var label : UILabel = {
        let label = UILabel()
        label.textColor = .black
        label.font = .boldSystemFont(ofSize: 15)
        return label
    }()
    
    required init?(coder: NSCoder) {
        fatalError("fatalError")
    }
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        self.addSubview(imageview)
        self.addSubview(label)
    }
}
