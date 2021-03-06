//
//  ViewPostingController.swift
//  MakeFairytale
//
//  Created by ByungHoon Ann on 2019/10/19.
//  Copyright © 2019 ByungHoon Ann. All rights reserved.
//

import Foundation
import UIKit
import SDWebImage
import Firebase

fileprivate let currentUID = Auth.auth().currentUser?.uid
fileprivate let postRef = Firestore.firestore().posts

class ViewPostingController : UIViewController ,UITextFieldDelegate, PostImageCollectionViewDelegate, AlertPresentable {
    

    @IBOutlet weak var contentView: UIView!
    @IBOutlet weak var pageControl: UIPageControl!
    @IBOutlet weak var viewRepleButton: UIButton!
    @IBOutlet weak var scrollContentViewNSLayoutConstraint: NSLayoutConstraint!
    @IBOutlet weak var likeCountLabel: UILabel!
    @IBOutlet weak var viewCountLabel: UILabel!
    @IBOutlet weak var nsKeyboardConstrait: NSLayoutConstraint!
    @IBOutlet weak var profileImageView: UIImageView!
    @IBOutlet var userName: [UILabel]!
    @IBOutlet weak var userComment: UILabel!
    @IBOutlet weak var mySelfProfileImageView: UIImageView!
    @IBOutlet weak var goodMark : UIButton!
    @IBOutlet weak var repleTextField: UITextField!
    @IBOutlet weak var hideRepleList: UITableView!
    @IBOutlet weak var repleListHeightNSLayoutConstraint: NSLayoutConstraint!
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var postDateLabel: UILabel!
    
    var collectionView = PostImageCollectionView()
    lazy var label : UILabel = {
       let label = UILabel()
        label.text = "아직 댓글이 없습니다. \n 친구에게 처음으로 댓글을 남겨보세요!"
        label.textColor = .black
        label.font = .boldSystemFont(ofSize: 15)
        label.numberOfLines = 0
        label.isHidden = true
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    lazy var dateFomatter = DateCalculation.shread.dateFomatter
    lazy var today = Today.shread.today
    var optionAlertComponents: AlertComponents {
        return selectAlertType(by: CommonService.shread.orderSelect)
    }
    
    let calendar = Calendar(identifier: .gregorian)
    var post: Posts?
    var repleData : [RepleData] = [] {
        didSet {
            repleData.sort { firstData, secondData in
                let dateFirstData = dateFomatter.date(from: firstData.repleDate) ?? today
                let dateSecondData = dateFomatter.date(from: secondData.repleDate) ?? today
                if dateFirstData > dateSecondData {
                    return true
                }else {
                    return false
                }
            }
        }
    }
    
    override func viewDidLoad() {
        guard let post = post else { return }
        pageControl.currentPage = 0
        pageControl.numberOfPages = post.userPostImage.count
        hideRepleList.delegate = self
        hideRepleList.dataSource = self
        repleTextField.layer.borderWidth = 0.5
        repleTextField.layer.borderColor = UIColor.gray.cgColor
        
        hideRepleList.registerCell(ViewPostingRepleCell.self)
        
        checkViewCount()
        customFrame()
        viewPostingData()
        customRepleFunc()
        collectionViewSetUp()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        guard let post = post else { return }
        if post.userPostImage.count == 1 { pageControl.isHidden = true
        } else {
            pageControl.isHidden = false
        }
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow(notification:)), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide(notification:)), name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        NotificationCenter.default.removeObserver(self)
    }
    
    @objc func keyboardWillShow(notification: Notification) {
        if let keyboardSize = (notification.userInfo![UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue {
            nsKeyboardConstrait.constant = keyboardSize.height - 10
        }
        UIView.animate(withDuration: 0, animations: {
            self.view.layoutIfNeeded()
        },completion: { complete in
        })
    }
    
    @objc func keyboardWillHide(notification: Notification) {
        nsKeyboardConstrait.constant = 0
        view.layoutIfNeeded()
    }
    
    @objc func dismisskeyboard() {
        view.endEditing(true)
    }
    
    @objc func goProfileVC(_ sender: UITapGestureRecognizer) {
        guard let post = post else { return }
        guard let currentUID = currentUID else { return }
        guard let vc = UIStoryboard.myFestaStoryVC() else { return }
        vc.firstMyView.myUID = currentUID
        CurrentUID.shread.nickName = post.userName
        CurrentUID.shread.profileURL = post.userProfileImage
        CurrentUID.shread.yourUID = post.userUID
        navigationController?.pushViewController(vc, animated: true)
    }
    
    @IBAction func moveChattingViewButton(_ sender: UIButton) {
        guard let userUID = post?.userUID else { return }
        guard let vc = UIStoryboard.chattingRoomVC() else { return }
        CurrentUID.shread.yourUID = userUID
        navigationController?.pushViewController(vc, animated: true)
    }
    
    @IBAction func repleButton(_ sender: UIButton ) {
        if let myData = FirebaseServices.shread.myProfile {
            uploadReple(myData) { [weak self] in
                guard let self = self else { return }
                self.label.isHidden = true
                self.hideRepleList.reloadData()
            }
        }
    }
    
    @IBAction func likeAction(_ sender: UIButton) {
        guard let _post = post else { return }
    
        guard let currentUID = currentUID else { return }
        let today = dateFomatter.string(from: self.today)
        
        
        if sender.isSelected == false {
            sender.isSelected = true
            post?.likeCount += 1
            likeCountLabel.text = "\(_post.likeCount + 1) 좋아요"
            
        }else {
            sender.isSelected = false
            post?.likeCount -= 1
            likeCountLabel.text = "\(_post.likeCount - 1 ) 좋아요"
        }

        DispatchQueue.main.async {
            self.likeButtonAction(today, _post, currentUID) { }
        }
    }
    
    func collectionViewSetUp() {
        contentView.addSubview(collectionView)
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        collectionView.topAnchor.constraint(equalTo: contentView.topAnchor).isActive = true
        collectionView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor).isActive = true
        collectionView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor).isActive = true
        collectionView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor).isActive = true
    }
    
    func customFrame() {
        profileImageView.layer.cornerRadius = profileImageView.frame.height/2
        mySelfProfileImageView.layer.cornerRadius = mySelfProfileImageView.frame.height/2
    }
    
    @IBAction func BackListVCButton(_ sender: Any) {
        navigationController?.popViewController(animated: true)
    }
    
    @IBAction func moveRepleList(_ sender: UIButton) {
        viewRepleActionCustom()
    }
    
    @IBAction func optionButton(_ sender: Any) {
        presentAlert(.actionSheet)
    }
    
    func viewPostingData () {
        guard let post = post else { return }
    
        profileImageView.sd_setImage(with: URL(string: post.userProfileImage))
        userName[0].text = post.userName
        userName[1].text = post.userName
        userComment.text = post.userComment
        viewCountLabel.text = "조회 \(post.viewCount)명"
        goodMark.isSelected = post.goodMark
        
        likeCountLabel.text = post.goodMark ? "\(post.likeCount) 좋아요":"\(post.likeCount - 1) 좋아요"
    
        print(post.goodMark,post.userUID,post.likeCount)
        if likeCountLabel.text == "-1 좋아요" {
            likeCountLabel.text = "0 좋아요"
        }
        
        mySelfProfileImageView.sd_setImage(with: URL(string: post.userProfileImage))
        collectionView.postURLs = post.userPostImage
        
        postDateLabel.text = DateCalculation.shread.requestDate(post.postDate,
                                                                dateFomatter,
                                                                today,
                                                                calendar)
    }
    
    func customRepleFunc() {
        repleTextField.delegate = self
        profileImageView.isUserInteractionEnabled = true
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(goProfileVC))
        profileImageView.addGestureRecognizer(tapGesture)
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(dismisskeyboard))
        view.addGestureRecognizer(tap)
    }
    
    func pageControlCurrentPageIndex(_ path: Int) {
        pageControl.currentPage = path
    }
}

extension ViewPostingController : UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return repleData.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard indexPath.row < repleData.count else {
            label.isHidden = false
            return UITableViewCell() }
        let cell:ViewPostingRepleCell = tableView.dequeueCell(indexPath: indexPath)
        cell.repleData = repleData[indexPath.row]
        return cell
    }
}

extension ViewPostingController {
    func viewRepleActionCustom() {
        let cell = ViewPostingRepleCell()
        let bottomOffset = CGPoint(x: viewRepleButton.frame.minX, y: userComment.frame.minY)
        let topOffset = CGPoint(x: scrollView.frame.minX, y: scrollView.frame.minY)
        
        repleData.removeAll()
        guard let postData = post else { return }
        
        if hideRepleList.isHidden == true {
            FirebaseServices.shread.loadPostRepleDatas(uid: postData.userUID,
                                                       postDate: postData.postDate,
                                                       imageURL: postData.userPostImage) { [weak self] in
                                                        guard let self = self else { return }
                                                        self.repleData = FirebaseServices.shread.repleDatas
                                                        
                                                        self.hideRepleList.reloadData()
                                                        self.hideRepleList.isHidden = false
                                                        
                                                        UIView.animate(withDuration: 3, delay: 0, options: .transitionFlipFromBottom, animations: {
                                                            if self.repleData.isEmpty == true {
                                                                self.label.isHidden = false
                                                                self.scrollView.addSubview( self.label)
                                                                self.label.centerXAnchor.constraint(equalTo: self.scrollView.centerXAnchor).isActive = true
                                                                self.label.centerYAnchor.constraint(equalTo: self.hideRepleList.centerYAnchor).isActive = true
                                                            }
                                                            
                                                            self.repleListHeightNSLayoutConstraint.constant = cell.frame.height * CGFloat(self.repleData.count)
                                                            print(self.repleListHeightNSLayoutConstraint.constant)
                                                            self.hideRepleList.reloadData()
                                                            self.hideRepleList.isHidden = false
                                                            
                                                            if self.repleData.count != 0 {
                                                                self.viewRepleButton.setTitle("접기", for: .normal)
                                                            }
                                                        }, completion: nil)
                                                        self.scrollView.setContentOffset(bottomOffset, animated: true)
            }
        } else {
            label.isHidden = true
            if repleData.count != 0 {
                viewRepleButton.setTitle("\(repleData.count)개 댓글 보기", for: .normal)
            }
            UIView.animate(withDuration: 1, delay: 0, options: .transitionFlipFromTop, animations: {
                self.hideRepleList.isHidden = true
                
                self.repleListHeightNSLayoutConstraint.constant = 50
                self.scrollView.layoutIfNeeded()
            },completion: nil)
            
            scrollView.setContentOffset(topOffset, animated: true)
        }
    }
    
    func uploadReple(_ myData: MyProfile,completion: @escaping () -> Void) {
        guard let reple = repleTextField.text else {return }
        guard let post = post else { return }
        guard let currentUID = CurrentUID.shread.currentUID else { return }
        let repleDate = dateFomatter.string(from: today)
        let message = "님이 게시물에 댓글을 작성하셨습니다."
        if !reple.isEmpty {
            repleData.removeAll()
            FirebaseServices.shread.replUploadService(post.userUID, currentUID, myData.profileImageURL, reple, repleDate, post.urlkey, myData.nickName+message, myData.nickName) {
                if currentUID != post.userUID {
                    Firestore
                        .firestore()
                        .alertContentsCenter("reple", post.userUID)
                }
                FirebaseServices.shread.loadPostRepleDatas(uid: post.userUID, postDate: post.postDate, imageURL: post.userPostImage) {
                    
                    self.repleData = FirebaseServices.shread.repleDatas
                    completion()
                }
            }
        }
    }
    
    
    func checkViewCount() {
        DispatchQueue.main.async {
            guard let post = self.post else { return  }
            guard let currentUID = currentUID else { return }
            postRef
                .document(post.urlkey)
                .collection("ViewCheck")
                .document(currentUID)
                .setData([currentUID:true])
        }
    }
}

