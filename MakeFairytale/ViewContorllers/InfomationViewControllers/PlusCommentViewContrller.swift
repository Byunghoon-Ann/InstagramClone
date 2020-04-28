//
//  PlusCommentViewContrller.swift
//  MakeFairytale
//
//  Created by ByungHoon Ann on 03/10/2019.
//  Copyright © 2019 ByungHoon Ann. All rights reserved.
//

import UIKit
import Firebase

fileprivate let postRef = Firestore.firestore().posts

class PlusCommentViewContrller : UIViewController {
    @IBOutlet weak var nsBottomConstraint: NSLayoutConstraint!
    @IBOutlet weak var profileImgView: UIImageView!     //게시글 주인 프로필이미지뷰
    @IBOutlet weak var profileComment: UILabel!    //게시글 주인의 글
    @IBOutlet weak var commentTableView: UITableView!    //댓글테이블뷰
    @IBOutlet weak var checkUIBtn: UIButton! //댓글입력 버튼
    @IBOutlet weak var plusCommentTextField: UITextField!
    @IBOutlet weak var mySelfImgView: UIImageView!
    
    lazy var alertLabel : UILabel = {
        let label = UILabel()
        label.textAlignment = .center
        label.textColor = .black
        label.backgroundColor = .white
        label.font = .boldSystemFont(ofSize: 16)
        label.text = "댓글이 아직 없습니다"
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    lazy var dateFomatter: DateFormatter = {
        return DateCalculation.shread.dateFomatter
    }()
    
    var post:Posts? {
        return Post.shread.post
    }
    
    var postData: Posts?
    var myData : MyProfile? {
        return FirebaseServices.shread.myProfile
    }
    var repleData : [RepleData] = [] {
        willSet {
            self.repleData.removeAll()
        }
        didSet {
            if repleData.isEmpty {
                commentTableView.isHidden = true
                alertLabel.isHidden = false
            } else {
                commentTableView.reloadData()
                commentTableView.isHidden = false
                alertLabel.isHidden = true
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        customAlertLabel()
        checkUIBtn.backgroundColor = .white
        plusCommentTextField.textColor = .black
        plusCommentTextField.backgroundColor = .white
        profileComment.backgroundColor = .white
        profileComment.textColor = .black
        
        checkUIBtn.setTitleColor(.black, for: .normal)
        commentTableView.dataSource = self
        commentTableView.delegate = self
        commentTableView.backgroundColor = .white
        plusCommentTextField.delegate = self
        
        commentTableView.layer.borderWidth = 0.3
        commentTableView.layer.borderColor = UIColor.gray.cgColor
        profileImgView.layer.cornerRadius = profileImgView.frame.height/2
        mySelfImgView.layer.cornerRadius = mySelfImgView.frame.height/2
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target:self, action: #selector(dismisskeyboard))
        view.addGestureRecognizer(tap)
        
        requestRepleData()
    }
    
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        guard let _post = post, let _myData = myData  else { return }

        self.profileImgView.sd_setImage(with: URL(string: _post.userProfileImage))
        self.profileComment.text = _post.userName
        self.mySelfImgView.sd_setImage(with: URL(string: _myData.profileImageURL))
        
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow(notification:)), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide(notification:)), name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        NotificationCenter.default.removeObserver(self)
    }
    
    @objc func keyboardWillShow(notification: Notification) {
        if let keyboardSize = (notification.userInfo![UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue {
            self.nsBottomConstraint.constant = keyboardSize.height + 10
        }
        UIView.animate(withDuration: 0, animations: {
            self.view.layoutIfNeeded()
        },completion: { complete in
            if self.repleData.count > 0 {
                self.commentTableView.scrollToRow(at: IndexPath(item: self.repleData.count - 1, section: 0), at: .bottom, animated: true)
            }
        })
    }
    
    @objc func keyboardWillHide(notification: Notification) {
        nsBottomConstraint.constant = 20
        view.layoutIfNeeded()
    }
    
    @objc func dismisskeyboard() {
        view.endEditing(true)
    }
    
    @IBAction func backMainVCButton(_ sender: Any) {
        navigationController?.popViewController(animated: true)
    }
    
    //댓글버튼입력 
    @IBAction func checkBtn(_ sender: Any) {
        repleUpload(post,CurrentUID.shread.currentUID ,plusCommentTextField.text)
    }
    
    func repleUpload(_ post: Posts?, _ currentUID: String?, _ textfieldText: String?) {
        guard let post = post else { return }
        guard let currentUID = CurrentUID.shread.currentUID else { return }
        guard let reple = textfieldText else { return }
        
        let repleDate = dateFomatter.string(from: Today.shread.today)
        let message = "님이 게시물에 댓글을 작성하셨습니다."
        
        guard let myData = FirebaseServices.shread.myProfile else {return }
      
        DispatchQueue.main.async {
        Firestore
            .firestore()
            .collection("NotificationCenter")
            .document(post.userUID)
            .collection("alert")
            .addDocument(data: ["nickName":myData.nickName,
                                "date":repleDate,
                                "uid":myData.uid,
                                "url":post.urlkey,
                                "message":myData.nickName+message])
        postRef
            .document(post.urlkey)
            .collection("repleList")
            .addDocument(data: ["uid":currentUID,
                                "profileImageURL":myData.profileImageURL,
                                "reple":reple,
                                "nickName":myData.nickName,
                                "repleDate":repleDate]) { error in
                                    if let _error = error { print("\(_error.localizedDescription)")}
                                    if currentUID != post.userUID {
                                        Firestore
                                            .firestore()
                                            .alertContentsCenter("reple", post.userUID)
                                    }
                                    
                                    FirebaseServices.shread.loadPostRepleDatas(uid: post.userUID,
                                                                               postDate: post.postDate,
                                                                               imageURL: post.userPostImage) {
                                        self.repleData = FirebaseServices.shread.repleDatas
                                    }
                                  
            }
        }
    }
    
    func requestRepleData() {
        guard let post = post else { return }
        FirebaseServices.shread.loadPostRepleDatas(uid: post.userUID,
                                                   postDate: post.postDate,
                                                   imageURL: post.userPostImage) {
                                                    self.repleData = FirebaseServices.shread.repleDatas
        }
    }
}

extension PlusCommentViewContrller : UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return repleData.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard indexPath.row < repleData.count else { return UITableViewCell() }
        let cell:PlusCommentCell = tableView.dequeueCell(indexPath: indexPath)
        cell.repleData = repleData[indexPath.row]
        return cell
    }
}

extension PlusCommentViewContrller : UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 70
    }
}

extension PlusCommentViewContrller: UITextFieldDelegate {
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        if textField.text == "댓글입력칸" {
            textField.text = ""
        }
    }
}

extension PlusCommentViewContrller {
    func customAlertLabel() {
        view.addSubview(alertLabel)
        alertLabel.isHidden = true
        alertLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        alertLabel.centerYAnchor.constraint(equalTo: view.centerYAnchor).isActive = true
    }
}
