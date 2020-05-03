//
//  FollowListCell.swift
//  MakeFairytale
//
//  Created by ByungHoon Ann on 2020/05/01.
//  Copyright © 2020 ByungHoon Ann. All rights reserved.
//

import UIKit
import SDWebImage

class FollowListCell: UITableViewCell {
    
    @IBOutlet weak var profileImageView: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
    
    var checkType : CheckMode?
    
    var followData: FollowData? {
        didSet {
            guard let _followData = followData else { return }
            nameLabel.text = _followData.userName
            profileImageView.sd_setImage(with: URL(string: _followData.userThumbnail))
            guard let _checkType = checkType else { return }
            switch _checkType {
            case .following:
                dateLabel.text = "팔로우한 날짜: \(_followData.date)"
            case .follower:
                dateLabel.text = "팔로잉한 날짜: \(_followData.date)"
            }
        }
    }

    override func awakeFromNib() {
        super.awakeFromNib()
        profileImageView.layer.cornerRadius = profileImageView.frame.height/2
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        profileImageView.image = nil
        nameLabel.text = nil
        dateLabel.text = nil
    }
    
}
