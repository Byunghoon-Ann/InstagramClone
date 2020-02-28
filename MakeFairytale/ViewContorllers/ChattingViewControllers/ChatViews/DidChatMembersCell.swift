//
//  DidChatMembersCell.swift
//  MakeFairytale
//
//  Created by ByungHoon Ann on 2020/02/18.
//  Copyright © 2020 ByungHoon Ann. All rights reserved.
//

import UIKit

class DidChatMembersCell : UITableViewCell {
    
    @IBOutlet weak var profileImageView: UIImageView!
    @IBOutlet weak var nickName: UILabel!
    @IBOutlet weak var lastMessageLabel: UILabel!
    @IBOutlet weak var timeStampLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        profileImageView.layer.cornerRadius = profileImageView.frame.height/2
    }
}
