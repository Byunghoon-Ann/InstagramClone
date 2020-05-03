//
//  FeedCollectionCell.swift
//  MakeFairytale
//
//  Created by ByungHoon Ann on 10/10/2019.
//  Copyright © 2019 ByungHoon Ann. All rights reserved.
//

import UIKit
import SDWebImage

class FeedCollectionCell: UITableViewCell, PostImageCollectionViewDelegate {
    
    @IBOutlet weak var likeCountLabel: UILabel!
    @IBOutlet weak var postingDateLabel: UILabel!
    @IBOutlet weak var viewCount: UILabel! //조회수
    @IBOutlet weak var postUserProfileImg : UIImageView! //게시글 주인의 프로필 이미지뷰
    @IBOutlet weak var postUser: UILabel!  //해당게시글 유저의 닉네임
    @IBOutlet weak var moreOptionButton: UIButton! //alert 옵션 버튼
    @IBOutlet weak var goodBtn: UIButton!
    @IBOutlet weak var chattingButton: UIButton!
    @IBOutlet weak var postText: UILabel!  //게시글 텍스트내용
    @IBOutlet weak var mySelfImgView: UIImageView! //사용유저의 프로필사진
    @IBOutlet weak var moveRepleButton: UIButton! //댓글입력창
    @IBOutlet weak var pageControl: UIPageControl!     //이미지뷰 제어 pageControl
    @IBOutlet weak var postImageContentView: UIView!
    
    let calendar = Calendar(identifier: .gregorian)
    
    lazy var dateFomatter:DateFormatter = {
        return DateCalculation.shread.dateFomatter
    }()
    
    lazy var today:Date = {
        return Today.shread.today
    }()
    
    var myProfile: MyProfile? {
        didSet {
            guard let _myProfile = FirebaseServices.shread.myProfile else { return }
            mySelfImgView.sd_setImage(with: URL(string: _myProfile.profileImageURL))
        }
    }
    
    let postCollectionView = PostImageCollectionView()
    
    var festaData: Posts? {
        didSet {
            guard let festaData = festaData else { return }
            viewCount.text = "\(festaData.viewCount) 조회"
            postText.text = festaData.userComment
            postUser.text = festaData.userName
            postingDateLabel.text = DateCalculation.shread.requestDate(festaData.postDate,
                                                                       dateFomatter,
                                                                       today,
                                                                       calendar)
            postUserProfileImg.sd_setImage(with: URL(string: festaData.userProfileImage))
            likeCountLabel.text = "\(festaData.likeCount) 좋아요"
            goodBtn.isSelected = festaData.goodMark
            actionControlOption(festaData, pageControl)
            postImages = festaData.userPostImage
        }
    }
    
    var postImages = [String]()  {
        didSet {
            postCollectionView.postURLs = postImages
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        goodBtn.setImage(UIImage(named: "likeBefore.png"), for: .normal)
        goodBtn.setImage(UIImage(named: "likeAfter.png"), for: .selected)
        postUserProfileImg.layer.cornerRadius = postUserProfileImg.frame.height/2
        mySelfImgView.layer.cornerRadius = mySelfImgView.frame.height/2
        
        mySelfImgView.isUserInteractionEnabled = false
        pageControl.currentPage = 0
        AnimationControl.shread.tableCellHeight = self.frame.height
        postImageContentView.backgroundColor = .white
        postCollectionView.delegate = self
        setUpPostCollectionView(postCollectionView, postImageContentView)
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        viewCount.text = nil
        postText.text = nil
        postUser.text = nil
        postingDateLabel.text = nil
        postUserProfileImg.image = nil
        likeCountLabel.text = nil
        mySelfImgView.image = nil
        pageControl.currentPage = 0
    }
    
    func pageControlCurrentPageIndex(_ path: Int) {
        pageControl.currentPage = path
    }
    
    func setUpPostCollectionView(_ collectionView: UIView, _ contentView: UIView) {
        contentView.addSubview(collectionView)
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        collectionView.topAnchor.constraint(equalTo: contentView.topAnchor).isActive = true
        collectionView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor).isActive = true
        collectionView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor).isActive = true
        collectionView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor).isActive = true
    }
    
    @IBAction func moveRepleVC(_ sender: Any) {
        Post.shread.post = festaData
    }
    
    @IBAction func moveChatVC(_ sender: Any) {
        let userUID = festaData?.userUID ?? ""
        CurrentUID.shread.yourUID = userUID
    }
    
//    @IBAction func likeButtonAction(_ sender: UIButton) {
//        guard let likeCount = festaData?.likeCount else { return }
//
//        if sender.isSelected == true {
//            festaData?.likeCount -= 1
//            festaData?.goodMark = false
//            likeCountLabel.text = "\(festaData?.likeCount ?? likeCount - 1) 좋아요"
//            if likeCount < 0 {
//                likeCountLabel.text = "0 좋아요"
//            }
//        }else {
//            festaData?.likeCount += 1
//            festaData?.goodMark = true
//            likeCountLabel.text = "\(festaData?.likeCount ?? likeCount + 1) 좋아요"
//        }
//    }
    
}


