//
//  ViewPostingRepleCell.swift
//  MakeFairytale
//
//  Created by ByungHoon Ann on 2020/02/06.
//  Copyright © 2020 ByungHoon Ann. All rights reserved.
//

import UIKit
class ViewPostingRepleCell : UITableViewCell {
    
    @IBOutlet weak var userNameLabel: UILabel!
    @IBOutlet weak var repleTextLabel: UILabel!
    @IBOutlet weak var userProfileImageView: UIImageView!
    @IBOutlet weak var repleDateLabel: UILabel!
    
    var repleData: RepleData? {
        didSet {
            guard let repleData = repleData else{ return }
            userNameLabel.text = repleData.nickName
            repleTextLabel.text = repleData.userReple
            repleDateLabel.text = repleData.repleDate
            userProfileImageView.sd_setImage(with: URL(string: repleData.userThumbnail))
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        userProfileImageView.layer.cornerRadius = userProfileImageView.frame.height/2
    }
    
}
