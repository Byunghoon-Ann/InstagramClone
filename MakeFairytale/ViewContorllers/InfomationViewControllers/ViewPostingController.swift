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
fileprivate let firestoreRef = Firestore.firestore()

class ViewPostingController : UIViewController ,UITextFieldDelegate,UIScrollViewDelegate{
    
    @IBOutlet weak var pageControl: UIPageControl!
    @IBOutlet weak var postScrollView: UIScrollView!
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
    
    var label : UILabel = {
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
    
    let dateFomatter : DateFormatter = {
       let dateFomatter = DateFormatter()
       dateFomatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
       dateFomatter.locale = Locale(identifier: "kr_KR")
       return dateFomatter
    }()
    
    var post: Posts?
    var postNumber: Int?
    var likeNumber = 0
    var repleData : [RepleData] = []
    var postKey = ""
    let appDelegate = UIApplication.shared.delegate as! AppDelegate
    let cellName = "ViewPostingRepleCell"
    let date = Date()
    let calendar = Calendar(identifier: .gregorian)
    
    override func viewDidLoad() {
        guard let post = post else { return }
        postScrollView.delegate = self
        pageControl.currentPage = 0
        pageControl.numberOfPages = post.userPostImage.count
        goodMark.addTarget(self, action: #selector(likePostAction(_:)), for: .touchUpInside)
        checkViewCount()
        customFrame()
        viewPostingData()
        customRepleFunc()
        hideRepleList.delegate = self
        hideRepleList.dataSource = self
       
        let nibName = UINib(nibName: "ViewPostingRepleCell",bundle: nil)
        hideRepleList.register(nibName, forCellReuseIdentifier: "ViewPostingRepleCell")
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
            self.nsKeyboardConstrait.constant = keyboardSize.height - 35
        }
        UIView.animate(withDuration: 0, animations: {
            self.view.layoutIfNeeded()
        },completion: { complete in
        })
    }
    
    @objc func keyboardWillHide(notification: Notification) {
        self.nsKeyboardConstrait.constant = 0
        self.view.layoutIfNeeded()
    }
    
    @objc func dismisskeyboard() {
        self.view.endEditing(true)
    }
    
    @objc func goProfileVC(_ sender: UITapGestureRecognizer) {
        guard let post = post else { return }
        guard let currentUID = currentUID else { return }
        
        guard let vc = storyboard?.instantiateViewController(withIdentifier: "MyFestaStoryViewController") as? MyFestaStoryViewController else { return }
        vc.firstMyView.myUID = currentUID
        vc.firstMyView.yourUID = post.userUID
        vc.secondMyview.yourUID = post.userUID
        
        navigationController?.pushViewController(vc, animated: true)
    }
    
    @IBAction func moveChattingViewButton(_ sender: UIButton) {
        guard let post = post else { return }
        guard let vc = storyboard?.instantiateViewController(withIdentifier: "ChattingRoomViewController") as? ChattingRoomViewController else { return }
        vc.yourUID = post.userUID
        navigationController?.pushViewController(vc, animated: true)
    }
    
    @IBAction func repleButton(_ sender: UIButton ) {
        guard let post = post else { return }
        guard let reple = repleTextField.text else {return }
        let repleDate = dateFomatter.string(from: date)
        if let myData = appDelegate.myProfile {
            firestoreRef
                .collection("AllPost")
                .document(post.urlkey)
                .collection("repleList")
                .addDocument(data: ["uid":myData.uid,
                                    "profileImageURL":myData.profileImageURL,
                                    "reple":reple,
                                    "nickName":myData.nickName,
                                    "repleDate":repleDate])
            self.notificationAlert(myData.nickName,
                                   repleDate,
                                   myData.uid,
                                   post.userUID,
                                    "님이 게시물에 댓글을 남기셨습니다.",
                                   postKey)
            
            self.alertContentsCenter("reple",
                                     post.userUID)
            
            self.repleData.insert(RepleData(uid: myData.uid,
                                            userThumbnail: myData.profileImageURL,
                                            userReple: reple,
                                            nickName: myData.nickName,
                                            repleDate: repleDate),
                                  at: 0)
            self.hideRepleList.reloadData()
        }
    }
    
    @objc func likePostAction(_ sender: UIButton) {
        guard let post = post else { return }
        guard let currentUID = currentUID else { return }
        let likeCheckDate = dateFomatter.string(from: self.date)
        likeButtonAction(likeCheckDate,
                         post,
                         goodMark,
                         currentUID) {
                            
                            if sender.isSelected {
                                self.likeCountLabel.text = "\(post.likeCount + 1) 좋아요"
                            }else {
                                self.likeCountLabel.text = "\(post.likeCount - 1) 좋아요"
                            }
        }
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
    
    func viewPostingData () {
        guard let post = post else { return }
        profileImageView.sd_setImage(with: URL(string: post.userProfileImage))
        userName[0].text = post.userName
        userName[1].text = post.userName
        userComment.text = post.userComment
        viewCountLabel.text = "조회 \(post.viewCount)명"
        goodMark.isSelected = post.goodMark
        if post.goodMark == true {
            likeCountLabel.text = "\(post.likeCount) 좋아요"
        }
        else {
            likeCountLabel.text = "\(post.likeCount) 좋아요"
            if likeCountLabel.text == "-1 좋아요" {
                likeCountLabel.text = "0 좋아요"
            }
        }
        
        mySelfProfileImageView.sd_setImage(with: URL(string: post.userProfileImage))
        adScrollImageView(postScrollView,
                          post,
                          false)
        
        let dateString = dateFomatter.string(from: date)
        let today = dateFomatter.date(from: dateString) ?? date
        let postdates = dateFomatter.date(from: post.postDate) ?? date
        let calendarC = calendar.dateComponents([.year,.month,.day,.hour,.minute,.second], from: postdates,to: today)
        
        if case let (y?, m?, d?, h?, mi?, s?) = (calendarC.year, calendarC.month, calendarC.day, calendarC.hour,calendarC.minute,calendarC.second) {
            if y == 0, m == 0, d == 0, h == 0, mi == 0  {
                postDateLabel.text = "\(s)초 전"
            } else if y == 0, m == 0, d == 0, h == 0, mi >= 1 {
                postDateLabel.text = "\(mi)분 전"
            } else if y == 0, m == 0, d == 0, h >= 1 {
                postDateLabel.text = "\(h)시간 전"
            }else if  y == 0, m == 0, d >= 1{
                postDateLabel.text = "\(d)일 전"
            }else if y == 0, m >= 1, d >= 30 {
                postDateLabel.text = "\(m)개월 전"
            }else if y >= 1, m >= 12 {
                postDateLabel.text = "\(y)년 전"
            }
        }
    }
    
    func customRepleFunc() {
        repleTextField.delegate = self
        profileImageView.isUserInteractionEnabled = true
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(goProfileVC))
        profileImageView.addGestureRecognizer(tapGesture)
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(dismisskeyboard))
        view.addGestureRecognizer(tap)
    }
}

extension ViewPostingController : UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return repleData.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard repleData.count > 0 else {
            label.isHidden = false
            return UITableViewCell() }
        guard let cell = hideRepleList.dequeueReusableCell(withIdentifier: cellName) as? ViewPostingRepleCell else { return UITableViewCell() }
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
            LoadFile.shread.loadPostRepleDatas(uid: postData.userUID,
                                               postDate: postData.postDate,
                                               imageURL: postData.userPostImage) {
                                                self.repleData = LoadFile.shread.repleDatas
                                                
                                                self.repleData.sort { firstData, secondData in
                                                    let dateFirstData = self.dateFomatter.date(from: firstData.repleDate) ?? self.date
                                                    let dateSecondData = self.dateFomatter.date(from: secondData.repleDate) ?? self.date
                                                    if dateFirstData > dateSecondData {
                                                        return true
                                                    }else {
                                                        return false
                                                    }
                                                }
                                                
                                                self.hideRepleList.reloadData()
                                                self.hideRepleList.isHidden = false
                                                
                                                UIView.animate(withDuration: 3, delay: 0, options: .transitionFlipFromBottom, animations: {
                                                    if self.repleData.isEmpty == true {
                                                        self.label.isHidden = false
                                                        self.scrollView.addSubview( self.label)
                                                        self.label.centerXAnchor.constraint(equalTo: self.scrollView.centerXAnchor).isActive = true
                                                        self.label.centerYAnchor.constraint(equalTo: self.hideRepleList.centerYAnchor).isActive = true
                                                    }
                                                    
                                                    self.scrollContentViewNSLayoutConstraint.constant = self.scrollContentViewNSLayoutConstraint.constant + (cell.frame.height * CGFloat(self.repleData.count))
                                                    
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
                
                self.scrollContentViewNSLayoutConstraint.constant = self.scrollContentViewNSLayoutConstraint.constant - cell.frame.height * CGFloat(self.repleData.count)
                
                self.repleListHeightNSLayoutConstraint.constant = 50
                self.scrollView.layoutIfNeeded()
            },completion: nil)
            
            scrollView.setContentOffset(topOffset, animated: true)
        }
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if scrollView == postScrollView {
            pageControl.currentPage = Int(floor(postScrollView.contentOffset.x / UIScreen.main.bounds.width))
        }
    }
    
    func checkViewCount() {
        DispatchQueue.main.async {
            guard let post = self.post else { return  }
            guard let currentUID = currentUID else { return }
            firestoreRef.collection("AllPost")
                .document(post.urlkey)
                .collection("ViewCheck")
                .document(currentUID)
                .setData([currentUID:true])
        }
    }
}

