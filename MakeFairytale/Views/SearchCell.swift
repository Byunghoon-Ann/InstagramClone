//
//  SearchCell.swift
//  MakeFairytale
//
//  Created by ByungHoon Ann on 2020/02/06.
//  Copyright © 2020 ByungHoon Ann. All rights reserved.
//

import UIKit

class SearchCell : UICollectionViewCell {
    @IBOutlet weak var searchImageView: UIImageView!
    
    override func prepareForReuse() {
        super.prepareForReuse()
        searchImageView.image = nil
    }
}
