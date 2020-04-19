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
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        postUser.text = nil
        userName.text = nil
        userThumbnail.image = nil
    }
}
