//
//  PostImageCollectionCell.swift
//  MakeFairytale
//
//  Created by ByungHoon Ann on 2020/04/25.
//  Copyright © 2020 ByungHoon Ann. All rights reserved.
//

import UIKit
class PostImageCollectionCell: UICollectionViewCell {
    
    @IBOutlet weak var postImageView: UIImageView!

    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        postImageView.image = nil
    }
   
}
