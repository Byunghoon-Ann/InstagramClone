//
//  MarkViewCell.swift
//  MakeFairytale
//
//  Created by ByungHoon Ann on 2020/02/06.
//  Copyright © 2020 ByungHoon Ann. All rights reserved.
//

import UIKit

class MarkViewCell : UITableViewCell {
    @IBOutlet weak var profileImageView:UIImageView!
    @IBOutlet weak var userName: UILabel!
    @IBOutlet weak var userComment: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        userName.sizeToFit()
        userComment.sizeToFit()
        profileImageView.layer.cornerRadius = profileImageView.frame.height/2
    }
}
