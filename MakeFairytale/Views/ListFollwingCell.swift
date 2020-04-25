//
//  ListFollwingCell.swift
//  MakeFairytale
//
//  Created by ByungHoon Ann on 2020/02/06.
//  Copyright © 2020 ByungHoon Ann. All rights reserved.
//

import UIKit

class ListFollwingCell: UICollectionViewCell {
    
    @IBOutlet weak var follwingUserName : UILabel!
    @IBOutlet weak var follwingUserProfileImage: UIImageView!
   
    var followingData: FollowData? {
        didSet {
            guard let follwingData = followingData else { return }
            follwingUserName.text = follwingData.userName
            follwingUserProfileImage.sd_setImage(with: URL(string: follwingData.userThumbnail))
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        follwingUserProfileImage.layer.cornerRadius = follwingUserProfileImage.frame.height/2
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        follwingUserProfileImage.image = nil
        follwingUserName.text = nil
    }
}
