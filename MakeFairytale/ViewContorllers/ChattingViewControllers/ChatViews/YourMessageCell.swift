//
//  YourMessageCell.swift
//  MakeFairytale
//
//  Created by ByungHoon Ann on 2020/02/13.
//  Copyright © 2020 ByungHoon Ann. All rights reserved.
//

import UIKit

class YourMessageCell : UITableViewCell {
    
    @IBOutlet weak var readBoolLabel: UILabel!
    @IBOutlet weak var yourMessageCell: UILabel!
    @IBOutlet weak var yourNickName: UILabel!
    @IBOutlet weak var yourThumbnail: UIImageView!
    @IBOutlet weak var timeStampLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        yourThumbnail.layer.cornerRadius = yourThumbnail.frame.height/2
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        readBoolLabel.text = nil
        yourMessageCell.text = nil
        yourNickName.text = nil
        yourThumbnail.image = nil
        timeStampLabel.text = nil
    }
}
