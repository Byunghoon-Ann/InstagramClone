//
//  MyAlbumCollectionCell.swift
//  MakeFairytale
//
//  Created by ByungHoon Ann on 2020/02/06.
//  Copyright © 2020 ByungHoon Ann. All rights reserved.
//

import UIKit

class MyAlbumCollectionCell : UICollectionViewCell {
    
    @IBOutlet weak var albumImageView: UIImageView!
    @IBOutlet weak var selectedImageView: UIImageView!
    @IBOutlet weak var selectedView: UIView!
    var representAssetIdentifier: String?
    
    var thumbnailSize: CGSize {
        let scale = UIScreen.main.scale
        return CGSize(width: (UIScreen.main.bounds.width / 3) * scale, height: 100 * scale)
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        albumImageView.contentMode = .scaleAspectFill
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
    }
    
    override var isHighlighted: Bool {
        didSet {
            selectedView.isHidden = !isHighlighted
        }
    }
    
    override var isSelected: Bool {
        didSet {
            selectedView.isHidden = !isSelected
            selectedImageView.isHidden = !isSelected
        }
    }
    
    func configure(with image:UIImage?) {
        self.albumImageView.image = image
    }
}
