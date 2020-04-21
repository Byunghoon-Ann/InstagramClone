//
//  MyFestaStoryViewController.swift
//  MakeFairytale
//
//  Created by ByungHoon Ann on 2019/10/15.
//  Copyright © 2019 ByungHoon Ann. All rights reserved.
//
//MARK: 코드 출처 : 이동건의 이유있는 코드 https://baked-corn.tistory.com/111 에서 발췌 & 수정
import Foundation
import UIKit
import SDWebImage
import Firebase
import MobileCoreServices

fileprivate let databaseRef = Database.database().reference()
fileprivate let postRef = Firestore.firestore().posts
fileprivate let userRef = Firestore.firestore().user
fileprivate let followRef = Firestore.firestore().follow
fileprivate let folloerRef = Firestore.firestore().follower

class MyFestaStoryViewController: UIViewController, MyFestaStoryMenuViewDelegate,
MyViewsDelegate, MyPostTableViewDelegate, DidChattingCustomViewDelegate{
    
    @IBOutlet weak var FakeBarButton: UIButton!
    @IBOutlet weak var myProfileImage: UIImageView!
    @IBOutlet weak var myProfileName: UILabel!
    @IBOutlet var fixMyInfomation: UIButton!
    @IBOutlet weak var checkFollowButton: UIButton!
    @IBOutlet weak var horizontalStackView: UIStackView!
    @IBOutlet weak var guideCountLabelStackView: UIStackView!
    
    lazy var pageCollectionView: UICollectionView = {
        let collectionViewLayout = UICollectionViewFlowLayout()
        collectionViewLayout.scrollDirection = .horizontal
        let collectionView = UICollectionView(frame: CGRect(x: 0, y: 0, width: 0, height: 0), collectionViewLayout: collectionViewLayout)
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        collectionView.isPagingEnabled = true
        return collectionView
    }()
    
    lazy var dateFomatter : DateFormatter = {
       let dateFomatter = DateFormatter()
       dateFomatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
       dateFomatter.locale = Locale(identifier: "kr_KR")
       return dateFomatter
    }()
    
    var alertLabel : UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.numberOfLines = 2
        label.font = .boldSystemFont(ofSize: 20)
        label.textColor = .black
        label.text =  "타인의 채팅기록은 조회할 수 없습니다."
        label.textAlignment = .center
        return label
    }()
    
    let appDelegate = UIApplication.shared.delegate as! AppDelegate
    var myData: MyProfile?
    var customMenuBar = MyFestaStoryMenuView()
    var firstMyView = MyViews()
    var secondMyview = MyPostTableView()
    var thirdMyView = DidChattingCustomView()
    var myUID : String?
    var yourName: String = ""
    var followingCheck : [String] = []
    var followerCheck : [String] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        countLabelSetUp(horizontalStackView, false)
        countLabelSetUp(guideCountLabelStackView, true)
        setupCustomTabBar()
        setupPageCollectionView()
        myProfileName.text = yourName
    }
    
    override func viewWillAppear(_ animated: Bool) {
        if firstMyView.yourUID == "" || firstMyView
            .yourUID == appDelegate.currentUID{
            checkFollowButton.isHidden = true
        } else {
            checkFollowButton.isHidden = false
        }
        loadFollowCount()
        viewUserProfile(FakeBarButton, fixMyInfomation,
                        myProfileName, myProfileImage,
                        horizontalStackView) {
                     print("load Success")
        }
        myProfileImage.layer.cornerRadius = myProfileImage.bounds.height/2
        checkFollow()
    }

    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
    }
    
    //MARK: Following,UnFollow Button
    @IBAction func checkFollowButton(_ sender: Any) {
        followingCheckButton(checkFollowButton,
                             dateFomatter,
                             appDelegate,
                             secondMyview)
    }
    
    @IBAction func FakeBarButton(_ sender: Any) {
        navigationController?.popViewController(animated: true)
    }
    
    //MARK: 프로필 수정 화면 이동 버튼
    @IBAction func fixMyInfomation(_ sender: Any) {
        guard let vc = UIStoryboard.myStoryVC() else { return }
        navigationController?.pushViewController(vc, animated: true)
    }
    
    func setupCustomTabBar() {
        self.view.addSubview(customMenuBar)
        customMenuBar.delegate = self
        customMenuBar.translatesAutoresizingMaskIntoConstraints = false
        customMenuBar.indicatorViewWidthConstraint.constant = view.frame.width / 3
        customMenuBar.leadingAnchor.constraint(equalTo: self.view.leadingAnchor).isActive = true
        customMenuBar.trailingAnchor.constraint(equalTo: self.view.trailingAnchor).isActive = true
        customMenuBar.topAnchor.constraint(equalTo: fixMyInfomation.bottomAnchor,constant: 1).isActive = true
        customMenuBar.heightAnchor.constraint(equalToConstant: 60).isActive = true
    }
    
    func setupPageCollectionView() {
        pageCollectionView.delegate = self
        pageCollectionView.dataSource = self
        pageCollectionView.showsHorizontalScrollIndicator = false
        pageCollectionView.registerCell(MyFestaStoryPageCell.self)
        view.addSubview(pageCollectionView)
        
        pageCollectionView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor).isActive = true
        pageCollectionView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor).isActive = true
        pageCollectionView.bottomAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.bottomAnchor).isActive = true
        pageCollectionView.topAnchor.constraint(equalTo: self.customMenuBar.bottomAnchor,constant: 5).isActive = true
    }
    
    //MARK: Posting collectionView didSelectDelegate
    func customMyPostDidselect(_ path: Int) {
        moveDetailViewPostView(firstMyView,path)
    }
    
    func customMyPostTableDidselect(_ path: Int) {
        moveDetailViewPostView(firstMyView,path)
    }
    
    //MARK: MydidChattingList DIdSelectDelegate
    func customMyChatDidselect(_ path: Int) {
        let i = IndexPath(row:path,section:0)
        guard let vc = UIStoryboard.chattingRoomVC() else { return }
        vc.yourUID = thirdMyView.yourUIDs[i.row]
        navigationController?.pushViewController(vc, animated: true)
    }
    
    func countLabelSetUp(_ stackView: UIStackView, _  guide: Bool) {
        let guideText = ["게시물","팔로우","팔로잉"]
        for i in 0..<3 {
            let label = UILabel()
            label.textAlignment = .center
            label.font = .boldSystemFont(ofSize: 15)
            label.textColor = .black
            label.backgroundColor = .white
            if guide == true {
                label.text = guideText[i]
            }else {
                label.text = "0"
            }
            stackView.addArrangedSubview(label)
        }
    }
}

//MARK: Custom Tab Bar View Layout
extension MyFestaStoryViewController: UICollectionViewDataSource,UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 3
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell:MyFestaStoryPageCell = collectionView.dequeueCell(indexPath: indexPath)
        customInsertContentView(cell,indexPath)
        return cell
    }
    
    //MARK: CustomMenuBar에 indexPath를 받아서 didscroll로 pageViewCollection cell의 view화면과 이동을 구현
    func customMenuBar(scrollTo Index: Int) {
        let indexPath = IndexPath(row: Index, section: 0)
        pageCollectionView.scrollToItem(at: indexPath, at: .centeredHorizontally, animated: true)
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        customMenuBar.indicatorViewLeadingConstraint.constant = scrollView.contentOffset.x / 3
    }
    
    func scrollViewWillEndDragging(_ scrollView: UIScrollView, withVelocity velocity: CGPoint, targetContentOffset: UnsafeMutablePointer<CGPoint>) {
        let itemAt = Int(targetContentOffset.pointee.x / view.frame.width)
        let indexPath = IndexPath(item: itemAt,section: 0)
        customMenuBar.customTabBarCollectionView.selectItem(at: indexPath, animated: true, scrollPosition: [])
    }
}

extension MyFestaStoryViewController : UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: pageCollectionView.frame.width, height: pageCollectionView.frame.height)
    }
}

extension MyFestaStoryViewController {
    func customInsertContentView(_ cell: UICollectionViewCell, _ indexPath: IndexPath) {
        firstMyView.delegate = self
        secondMyview.delegate = self
        thirdMyView.delegate = self
        switch indexPath.row {
        case 0:
            setCustomCells(firstMyView, cell: cell)
        case 1:
            setCustomCells(secondMyview, cell: cell)
        case 2:
            setCustomCells(thirdMyView, cell: cell)
        default:
            print("Layout error!")
        }
    }
    
    func setCustomCells(_ view: UIView, cell: UICollectionViewCell) {
        if let view = view as? DidChattingCustomView {
            if firstMyView.yourUID == "" {
                view.isHidden = false
                alertLabel.isHidden = true
                cell.addSubview(thirdMyView)
            } else {
                view.isHidden = true
                alertLabel.isHidden = false
                cell.addSubview(alertLabel)
                alertLabel.centerXAnchor.constraint(equalTo: cell.centerXAnchor).isActive = true
                alertLabel.centerYAnchor.constraint(equalTo: cell.centerYAnchor).isActive = true
            }
        } else {
            cell.addSubview(view)
        }
        view.translatesAutoresizingMaskIntoConstraints = false
        view.isUserInteractionEnabled = true
        view.leadingAnchor.constraint(equalTo: cell.contentView.leadingAnchor).isActive = true
        view.trailingAnchor.constraint(equalTo: cell.contentView.trailingAnchor).isActive = true
        view.topAnchor.constraint(equalTo:cell.contentView.topAnchor).isActive = true
        view.bottomAnchor.constraint(equalTo: cell.contentView.bottomAnchor ).isActive = true
    }
    
    func loadFollowCount() {
        followingCheck.removeAll()
        followerCheck.removeAll()
        guard let currentUID = appDelegate.currentUID else { return }
        if secondMyview.yourUID != "" {
            followRef
                .document("\(secondMyview.yourUID)")
                .collection("FollowList")
                .getDocuments { snapshot,error in
                    
                    guard let snapshot = snapshot?.documents else { return }
                    for i in snapshot {
                        let data = i.data()
                        let uid = data["uid"] as? String ?? ""
                        self.followingCheck.append(uid)
                    }
                    if let followCountLabel = self.horizontalStackView.arrangedSubviews[2] as? UILabel {
                        followCountLabel.text = "\(snapshot.count)"
                    }
            }
            
            folloerRef
                .document("\(secondMyview.yourUID)")
                .collection("FollowerList")
                .getDocuments{ snapshot , error in
                    guard let snapshot = snapshot?.documents else {return}
                    for i in snapshot {
                        let data = i.data()
                        let uid = data["uid"] as? String ?? ""
                        self.followerCheck.append(uid)
                    }
                    if let followCountLabel = self.horizontalStackView.arrangedSubviews[1] as? UILabel {
                        followCountLabel.text = "\(snapshot.count)"
                    }
            }
        } else {
            folloerRef
                .document("\(currentUID)")
                .collection("FollowerList")
                .getDocuments { snapshot, error in
                    guard let snapshot = snapshot?.documents else {return}
                    
                    for i in snapshot {
                        let data = i.data()
                        let uid = data["uid"] as? String ?? ""
                        self.followerCheck.append(uid)
                    }
                    if let followCountLabel = self.horizontalStackView.arrangedSubviews[1] as? UILabel {
                        followCountLabel.text = "\(snapshot.count)"
                    }
            }
            
           folloerRef
                .document("\(currentUID)")
                .collection("FollowList")
                .getDocuments { snapshot,error in
                    guard let snapshot = snapshot?.documents else{return}
                    
                    for i in snapshot {
                        let data = i.data()
                        let uid = data["uid"] as? String ?? ""
                        self.followingCheck.append(uid)
                    }
                    if let followCountLabel = self.horizontalStackView.arrangedSubviews[2] as? UILabel {
                        followCountLabel.text = "\(snapshot.count)"
                    }
            }
        }
    }
    
    //MARK:- 사용자 혹은 타인의 프로필 조회시 발생하는 구별기능
    func viewUserProfile(_ backButton: UIButton, _ fixProfileButton: UIButton,
                         _ profileName: UILabel, _ profileImageView: UIImageView,
                         _ stackView: UIStackView,
                         completion : @escaping () -> Void) {
        guard let currentUID = appDelegate.currentUID else { return }
        backButton.isHidden = true
        
        if !firstMyView.yourUID.isEmpty, !secondMyview.yourUID.isEmpty {
            backButton.isHidden = false
            fixProfileButton.isUserInteractionEnabled = false
            fixProfileButton.isHidden = true
           
                userRef
                    .document("\(firstMyView.yourUID)")
                    .getDocument() { userData, error in
                        if let error = error {
                            print("profileLoadError! \(error.localizedDescription)")
                        }
                        
                        guard let userData = userData?.data() else { return }
                        
                        let userThumbnail = userData["profileImageURL"] as? String ?? ""
                        let nickName = userData["nickName"] as? String ?? ""
                        
                        profileName.text = nickName
                        profileImageView.sd_setImage(with: URL(string: userThumbnail))
            }
            
            postRef.order(by: firstMyView.yourUID).getDocuments { (query, error) in
                if let error = error {print("\(error.localizedDescription)") }
                if query?.isEmpty == true {
                    completion()
                } else {
                guard let query = query?.documents else { return }
                
                for document in query {
                    
                    guard let data = document.data() as? [String:[String:Any]] else { return }
                    let dataID = document.documentID
                    
                   postRef
                        .document(dataID)
                        .collection("ViewCheck")
                        .getDocuments { viewCheck,error in
                            
                            postRef
                                .document(dataID)
                                .collection("goodMarkLog")
                                .getDocuments { likeCount, error in
                                    
                                    for (_,j) in data {
                                        var viewCount = 0
                                        var likeCounts = 0
                                        
                                        let name = j["nickName"] as? String ?? ""
                                        let postComment = j["postComment"] as? String  ?? ""
                                        let postImageURL = j["postImageURL"] as? [String]  ?? [""]
                                        let date = j["date"] as? String  ?? ""
                                        let goodMark = j["goodMark"] as? Bool ?? false
                                        let profile = j["profileImageURL"] as? String  ?? ""
                                        let uid = j["uid"] as? String  ?? ""
                                       
                                        if let viewCheck = viewCheck {
                                            viewCount = viewCheck.count
                                        }
                                        
                                        if let likeCount = likeCount?.documents {
                                            for check in likeCount {
                                                let like = check["like"] as? Bool ?? false
                                                if like == true {
                                                    likeCounts += 1
                                                }
                                            }
                                        }
                                        
                                        self.firstMyView.myPosts.append(Posts(userUID: uid,
                                                                              userName: name,
                                                                              userComment: postComment,
                                                                              userProfileImage: profile,
                                                                              userPostImage: postImageURL,
                                                                              postDate: date,
                                                                              goodMark: goodMark,
                                                                              viewCount: viewCount,
                                                                              likeCount: likeCounts,
                                                                              urlkey:dataID))
                                        
                                        self.secondMyview.yourData.append(Posts(userUID: uid,
                                                                                userName: name,
                                                                                userComment: postComment,
                                                                                userProfileImage: profile,
                                                                                userPostImage: postImageURL,
                                                                                postDate: date,
                                                                                goodMark: goodMark,
                                                                                viewCount: viewCount,
                                                                                likeCount: likeCounts,
                                                                                urlkey:dataID))
                                        if query.count == self.firstMyView.myPosts.count,
                                            query.count == self.secondMyview.yourData.count  {
                                            
                                            self.secondMyview.tableView.reloadData()
                                            self.firstMyView.collectionView.reloadData()
                                            if let mypostCountLabel = stackView.arrangedSubviews[0] as? UILabel {
                                                mypostCountLabel.text = "\(query.count)"
                                            }
                                            completion()
                                        }
                                        
                                    }
                            }
                    }
                    }
                    completion()
                }
            }
        } else {
            firstMyView.myPosts.removeAll()
            secondMyview.yourData.removeAll()
            firstMyView.myPosts = appDelegate.myPost
            secondMyview.yourData = appDelegate.myPost
            myData = appDelegate.myProfile
            firstMyView.collectionView.reloadData()
            secondMyview.tableView.reloadData()
            
            FirebaseServices.shread.getChatRoomLists {
                self.thirdMyView.chatModel.removeAll()
                self.thirdMyView.chatModel = FirebaseServices.shread.chatModel
                self.thirdMyView.tableViews.reloadData()
            }
            
            userRef
                .document("\(currentUID)")
                .getDocument() { snapshot, error in
                    if let error = error {
                        print("\(error.localizedDescription)")
                    } else {
                        guard let snapshot = snapshot?.data() else { return }
                        
                        let nickName = snapshot["nickName"] as? String ?? ""
                        let email = snapshot["email"] as? String ??  ""
                        let profileImage = snapshot["profileImageURL"] as? String  ?? ""
                        self.myData = MyProfile(profileImageURL: profileImage, email: email, nickName: nickName, uid: currentUID)
                        guard let myData = self.myData else { return }
                        profileName.text = myData.nickName
                        profileImageView.sd_setImage(with: URL(string: myData.profileImageURL))
                        completion()
                    }
            }
            
            if let followCountLabel = stackView.arrangedSubviews[0] as? UILabel {
                followCountLabel.text = "\(appDelegate.myPost.count)"
            }
        }
    }
    
    func checkFollow() {
        guard let currentUID = appDelegate.currentUID else { return }
        let secondUID = secondMyview.yourUID
        if secondMyview.yourUID != "" {
                followRef
                .document("\(currentUID)")
                .collection("FollowList")
                .document(secondUID)
                .getDocument { (snapshot, error) in
                    guard let snapshot = snapshot?.data() else{
                        self.checkFollowButton.isSelected = false
                        return }
                    
                    guard let follow = snapshot["follow"] as? Bool else {
                        self.checkFollowButton.isSelected = false
                        return
                    }
                    self.checkFollowButton.isSelected = follow
            }
        }
    }
}
