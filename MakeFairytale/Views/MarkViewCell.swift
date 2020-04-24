//
//  MarkViewCell.swift
//  MakeFairytale
//
//  Created by ByungHoon Ann on 2020/02/06.
//  Copyright © 2020 ByungHoon Ann. All rights reserved.
//

import UIKit
import SDWebImage
class MarkViewCell : UITableViewCell {
    @IBOutlet weak var profileImageView:UIImageView!
    @IBOutlet weak var userName: UILabel!
    @IBOutlet weak var userComment: UILabel!
    
    var post: Posts? {
        didSet {
            guard let _post = post else { return }
            profileImageView.sd_setImage(with: URL(string: _post.userProfileImage))
            userName.text = _post.userName
            userComment.text = _post.userComment
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        userName.textColor = .black
        userName.backgroundColor = .white
        userComment.textColor = .black
        userComment.backgroundColor = .white
        profileImageView.layer.cornerRadius = profileImageView.frame.height/2
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        userName.text = nil
        userComment.text = nil
        profileImageView.image = nil
    }
}
