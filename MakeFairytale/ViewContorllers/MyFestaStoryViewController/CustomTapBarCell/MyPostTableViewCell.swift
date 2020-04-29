//
//  MyPostTableViewCell.swift
//  MakeFairytale
//
//  Created by ByungHoon Ann on 2019/10/23.
//  Copyright © 2019 ByungHoon Ann. All rights reserved.
//

import UIKit
import Firebase

class MyPostTableViewCell : UITableViewCell, UIScrollViewDelegate, PostImageCollectionViewDelegate {
 
    @IBOutlet weak var pageControl: UIPageControl!
    @IBOutlet weak var viewCountLabel: UILabel!
    @IBOutlet weak var chattingButton: UIButton!
    @IBOutlet weak var postUserProfileImg : UIImageView!
    @IBOutlet weak var postUser : UILabel!
    @IBOutlet weak var goodBtn : UIButton!
    @IBOutlet weak var viewPlusCommentBtn : UIButton!
    @IBOutlet weak var likeCountLabel:UILabel!
    @IBOutlet weak var postText : UILabel!
    @IBOutlet weak var mySelfImgView : UIImageView!
    @IBOutlet weak var postDateLabel: UILabel!
    @IBOutlet weak var postImageContentView: UIView!
    
    let calendar = Calendar(identifier: .gregorian)
    lazy var dateFomatter = DateCalculation.shread.dateFomatter
    
    var postData: Posts? {
        didSet {
            guard let postData = postData else { return }
            guard let myProfile = FirebaseServices.shread.myProfile else { return }
            postUserProfileImg.sd_setImage(with: URL(string: postData.userProfileImage))
            mySelfImgView.sd_setImage(with: URL(string: myProfile.profileImageURL))
            postText.text = postData.userComment
            postUser.text = postData.userName
            pageControl.numberOfPages = postData.userPostImage.count
            postDateLabel.text = DateCalculation.shread.requestDate(postData.postDate,
                                                                               dateFomatter,
                                                                               Today.shread.today,
                                                                               calendar)
            likeCountLabel.text = "\(postData.likeCount) 좋아요"
            viewCountLabel.text = "\(postData.viewCount) 조회"
            goodBtn.isSelected = postData.goodMark
            if postData.userPostImage.count == 1 {
                pageControl.isHidden = true
            }
            collectionView.postURLs = postData.userPostImage
        }
    }
    
    //테스트후 샘플영상 촬영
    override func awakeFromNib() {
        super.awakeFromNib()
        pageControl.currentPage = 0
        setUpcollectionView() 
        goodBtn.setImage(UIImage(named: "likeBefore.png"), for: .normal)
        goodBtn.setImage(UIImage(named: "likeAfter.png"), for: .selected)
        postUserProfileImg.layer.cornerRadius = postUserProfileImg.frame.height/2
        mySelfImgView.layer.cornerRadius = mySelfImgView.frame.height/2
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        postText.text = nil
        postUser.text = nil
        viewCountLabel.text = nil
        likeCountLabel.text = nil
        postUserProfileImg.image = nil
        likeCountLabel.text = nil
        mySelfImgView.image = nil
        postDateLabel.text = nil
    }
    
    func actionControlOption(_ festaData: Posts) {
        pageControl.numberOfPages = festaData.userPostImage.count
        if festaData.userPostImage.count == 1 {
            pageControl.isHidden = true
        }else {
            pageControl.isHidden = false
        }
    }
    
    var collectionView = PostImageCollectionView()
    func setUpcollectionView() {
        postImageContentView.addSubview(collectionView)
        collectionView.delegate = self
        collectionView.backgroundColor = .white
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        collectionView.topAnchor.constraint(equalTo: postImageContentView.topAnchor).isActive = true
        collectionView.bottomAnchor.constraint(equalTo: postImageContentView.bottomAnchor).isActive = true
        collectionView.leadingAnchor.constraint(equalTo: postImageContentView.leadingAnchor).isActive = true
        collectionView.trailingAnchor.constraint(equalTo: postImageContentView.trailingAnchor).isActive = true
    }

    func pageControlCurrentPageIndex(_ path: Int) {
        pageControl.currentPage = path
    }
}





