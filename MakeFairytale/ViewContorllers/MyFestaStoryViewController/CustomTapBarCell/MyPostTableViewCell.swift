//
//  MyPostTableViewCell.swift
//  MakeFairytale
//
//  Created by ByungHoon Ann on 2019/10/23.
//  Copyright © 2019 ByungHoon Ann. All rights reserved.
//

import UIKit
import Firebase
fileprivate let currentUID = Auth.auth().currentUser?.uid
class MyPostTableViewCell : UITableViewCell, UIScrollViewDelegate {
    
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
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var postDateLabel: UILabel!
    @IBOutlet weak var scrollContentView: UIView!
    
    let calendar = Calendar(identifier: .gregorian)
    var today = Date()
    lazy var dateFomatter: DateFormatter = {
        let dateFomatter = DateFormatter()
        dateFomatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        dateFomatter.locale = Locale(identifier: "kr_KR")
        return dateFomatter
    }()
    
    var postData: Posts? {
        didSet {
            guard let postData = postData else { return }
            postUserProfileImg.sd_setImage(with: URL(string: postData.userProfileImage))
            mySelfImgView.sd_setImage(with: URL(string: postData.userProfileImage))
            postText.text = postData.userComment
            postUser.text = postData.userName
            goodBtn.isSelected = postData.goodMark
            pageControl.numberOfPages = postData.userPostImage.count
            postDateLabel.text = postingDateCalculation(postData.postDate,dateFomatter,today,calendar)
            likeCountLabel.text = "\(postData.likeCount) 좋아요"
            viewCountLabel.text = "\(postData.viewCount) 조회"
            goodBtn.isSelected = postData.goodMark
            if postData.userPostImage.count == 1 {
                pageControl.isHidden = true
            }
        }
    }
    //테스트후 샘플영상 촬영
    override func awakeFromNib() {
        super.awakeFromNib()
        pageControl.currentPage = 0
        
        scrollView.delegate = self
        scrollContentView.isHidden = true
        postUserProfileImg.layer.cornerRadius = postUserProfileImg.frame.height/2
        mySelfImgView.layer.cornerRadius = mySelfImgView.frame.height/2
    }
    
    
    func actionControlOption(_ festaData: Posts) {
        pageControl.numberOfPages = festaData.userPostImage.count
        if festaData.userPostImage.count == 1 {
            pageControl.isHidden = true
        }else {
            pageControl.isHidden = false
        }
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        pageControl.currentPage = Int(floor(scrollView.contentOffset.x / UIScreen.main.bounds.width))
    }
}




