//
//  PlusCommentCell.swift
//  MakeFairytale
//
//  Created by ByungHoon Ann on 2020/02/16.
//  Copyright © 2020 ByungHoon Ann. All rights reserved.
//

import UIKit

//댓글 테이블뷰 셀
class PlusCommentCell : UITableViewCell {
    //댓글뷰의 게시글 주인의 글 내용
    @IBOutlet weak var postUser : UILabel!
    @IBOutlet weak var userName: UILabel!
    @IBOutlet weak var userThumbnail:UIImageView!

    var repleData: RepleData? {
        didSet {
            guard let _repleData = repleData else {  return }
            postUser.text = _repleData.userReple
            userName.text = _repleData.nickName
            userThumbnail.sd_setImage(with: URL(string: _repleData.userThumbnail))
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        self.backgroundColor = .white
        self.contentView.layer.borderWidth = 0.1
        self.contentView.layer.borderColor = UIColor.lightGray.cgColor
        
        userName.backgroundColor = .white
        userName.textColor = .black
        postUser.backgroundColor = .white
        postUser.textColor = .black
        
        userThumbnail.layer.cornerRadius = userThumbnail.frame.height/2
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        postUser.text = nil
        userName.text = nil
        userThumbnail.image = nil
    }
}
