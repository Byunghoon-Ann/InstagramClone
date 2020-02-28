//
//  MyMessageCell.swift
//  MakeFairytale
//
//  Created by ByungHoon Ann on 2020/02/13.
//  Copyright © 2020 ByungHoon Ann. All rights reserved.
//

import UIKit
class MyMessageCell : UITableViewCell {
    
    @IBOutlet weak var readBoolLabel: UILabel!
    @IBOutlet weak var myMessageLabel: UILabel!
    @IBOutlet weak var myNickName: UILabel!
    @IBOutlet weak var myThumbnail: UIImageView!
    @IBOutlet weak var timeStampLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        myThumbnail.layer.cornerRadius = myThumbnail.frame.height/2
    }
    
}
