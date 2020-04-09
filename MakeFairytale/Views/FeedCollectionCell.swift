//
//  FeedCollectionCell.swift
//  MakeFairytale
//
//  Created by ByungHoon Ann on 10/10/2019.
//  Copyright © 2019 ByungHoon Ann. All rights reserved.
//

import UIKit
import Firebase
import SDWebImage
fileprivate let firestoreRef = Firestore.firestore()
fileprivate let currentUID = Auth.auth().currentUser?.uid
class FeedCollectionCell: UITableViewCell, UIScrollViewDelegate{
    @IBOutlet weak var postImageScrollView: UIScrollView!
    @IBOutlet weak var likeCountLabel: UILabel!
    @IBOutlet weak var postingDateLabel: UILabel!
    @IBOutlet weak var viewCount: UILabel! //조회수
    @IBOutlet weak var postUserProfileImg : UIImageView! //게시글 주인의 프로필 이미지뷰
    @IBOutlet weak var postUser : UILabel!  //해당게시글 유저의 닉네임
    @IBOutlet weak var moreOptionButton: UIButton! //alert 옵션 버튼
    @IBOutlet weak var goodBtn : UIButton!
    @IBOutlet weak var chattingButton: UIButton!
    @IBOutlet weak var postText : UILabel!  //게시글 텍스트내용
    @IBOutlet weak var mySelfImgView : UIImageView! //사용유저의 프로필사진
    @IBOutlet weak var moveRepleButton: UIButton! //댓글입력창
    @IBOutlet weak var pageControl: UIPageControl!     //이미지뷰 제어 pageControl
    @IBOutlet weak var scrollContentView: UIView!
    
    let appDelegate = UIApplication.shared.delegate as! AppDelegate
    let calendar = Calendar(identifier: .gregorian)
    var today = Date()
    lazy var dateFomatter: DateFormatter = {
        let dateFomatter = DateFormatter()
        dateFomatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        dateFomatter.locale = Locale(identifier: "kr_KR")
        return dateFomatter
    }()
    
    var myProfile: MyProfile? {
        didSet {
            guard let myProfileData = myProfile else { return }
            mySelfImgView.sd_setImage(with: URL(string: myProfileData.profileImageURL))
        }
    }

    var festaData: Posts? {
        didSet {
            guard let festaData = festaData else { return }
            viewCount.text = "\(festaData.viewCount) 조회"
            postText.text = festaData.userComment
            postUser.text = festaData.userName
            postingDateLabel.text = postingDateCalculation(festaData.postDate,dateFomatter,today,calendar)
            postUserProfileImg.sd_setImage(with: URL(string: festaData.userProfileImage))
            likeCountLabel.text = "\(festaData.likeCount) 좋아요"
            goodBtn.isSelected = festaData.goodMark
            actionControlOption(festaData, pageControl)
            
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        goodBtn.setImage(UIImage(named: "likeBefore.png"), for: .normal)
        goodBtn.setImage(UIImage(named: "likeAfter.png"), for: .selected)
        postImageScrollView.delegate = self
        scrollContentView.isHidden = true
        postUserProfileImg.layer.cornerRadius = postUserProfileImg.frame.height/2
        mySelfImgView.layer.cornerRadius = mySelfImgView.frame.height/2
        mySelfImgView.isUserInteractionEnabled = false
        pageControl.currentPage = 0
        appDelegate.tableCellHeight = self.frame.height
    }
    
    

    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        pageControl.currentPage = Int(floor(scrollView.contentOffset.x / UIScreen.main.bounds.width))
    }
}


