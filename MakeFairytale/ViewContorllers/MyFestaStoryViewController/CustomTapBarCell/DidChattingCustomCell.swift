//
//  DidChattingCustomCell.swift
//  MakeFairytale
//
//  Created by ByungHoon Ann on 2019/11/05.
//  Copyright © 2019 ByungHoon Ann. All rights reserved.
//

import Foundation
import UIKit

class DidChattingCustomCell : UITableViewCell {
    
    @IBOutlet weak var profileImageview: UIImageView!
    @IBOutlet weak var nickNameLabel: UILabel!
    @IBOutlet weak var lastMessage: UILabel!
    @IBOutlet weak var timeStamps: UILabel!
   
    var alertLabel : UILabel = {
       let label = UILabel()
        label.text = "타인의 채팅기록은 조회를 할 수가 없습니다."
        label.textAlignment = .center
        label.font = UIFont.boldSystemFont(ofSize: 30)
        label.textColor = .black
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    override func awakeFromNib() {
        super.awakeFromNib()
        profileImageview.layer.cornerRadius = profileImageview.frame.height/2
        addSubview(alertLabel)
        alertLabel.isHidden = true
        alertLabel.centerXAnchor.constraint(equalTo: self.centerXAnchor).isActive = true
        alertLabel.centerYAnchor.constraint(equalTo: self.centerYAnchor).isActive = true
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        timeStamps.text = nil
        nickNameLabel.text = nil
        lastMessage.text = nil
        profileImageview.image = nil
    }
}
