//
//  MyFestaStoryViewController.swift
//  MakeFairytale
//
//  Created by ByungHoon Ann on 2019/10/15.
//  Copyright © 2019 ByungHoon Ann. All rights reserved.
//
//MARK: 코드 출처 : 이동건의 이유있는 코드 https://baked-corn.tistory.com/111 에서 발췌 & 수정
import UIKit
import SDWebImage
import Firebase
import MobileCoreServices

fileprivate let databaseRef = Database.database().reference()
fileprivate let postRef = Firestore.firestore().posts
fileprivate let userRef = Firestore.firestore().user

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
    
    lazy var alertLabel : UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.numberOfLines = 2
        label.font = .boldSystemFont(ofSize: 20)
        label.textColor = .black
        label.text =  "타인의 채팅기록은 조회할 수 없습니다."
        label.textAlignment = .center
        return label
    }()
    
    var myData: MyProfile?
    var customMenuBar = MyFestaStoryMenuView()
    var firstMyView = MyViews()
    var secondMyview = MyPostTableView()
    var thirdMyView = DidChattingCustomView()
    var myUID : String?
    var yourName: String = ""
    var followingCheck : [String] = [] {
        willSet {
            self.followingCheck.removeAll()
        }
    }
    
    var followerCheck : [String] = [] {
        willSet {
            self.followerCheck.removeAll()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        countLabelSetUp(horizontalStackView, false)
        countLabelSetUp(guideCountLabelStackView, true)
        setupCustomTabBar()
        setupPageCollectionView()
        myProfileName.text = yourName
    }
    
    override func viewWillAppear(_ animated: Bool) {
        if firstMyView.yourUID == "" || firstMyView.yourUID == CurrentUID.shread.currentUID {
            checkFollowButton.isHidden = true
        } else {
            checkFollow()
            checkFollowButton.isHidden = false
        }
        loadFollowCount()
        viewUserProfile(FakeBarButton, fixMyInfomation,
                        myProfileName, myProfileImage,
                        horizontalStackView) {
                            print("load Success")
        }
        myProfileImage.layer.cornerRadius = myProfileImage.bounds.height/2
    }

    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        FakeBarButton.isHidden = true
        fixMyInfomation.isHidden = false
    }
    
    //MARK: Following,UnFollow Button
    @IBAction func checkFollowButton(_ sender: Any) {
        followingCheckButton(checkFollowButton, dateFomatter, secondMyview)
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
        CurrentUID.shread.yourUID = thirdMyView.yourUIDs[i.row]
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
extension MyFestaStoryViewController: UICollectionViewDataSource, UICollectionViewDelegate {
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
            checkCustomCells(firstMyView, cell: cell)
        case 1:
            checkCustomCells(secondMyview, cell: cell)
        case 2:
            checkCustomCells(thirdMyView, cell: cell)
        default:
            print("Layout error!")
        }
    }
    
    func checkCustomCells(_ view: UIView, cell: UICollectionViewCell) {
        if let view = view as? DidChattingCustomView {
            if firstMyView.yourUID == "" {
                view.isHidden = false
                alertLabel.isHidden = true
                setCustomView(view, cell)
            } else {
                view.isHidden = true
                alertLabel.isHidden = false
                cell.addSubview(alertLabel)
                alertLabel.centerXAnchor.constraint(equalTo: cell.centerXAnchor).isActive = true
                alertLabel.centerYAnchor.constraint(equalTo: cell.centerYAnchor).isActive = true
            }
        } else {
            setCustomView(view, cell)
        }
    }
    
    func setCustomView(_ view: UIView, _ cell: UICollectionViewCell) {
        cell.addSubview(view)
        view.translatesAutoresizingMaskIntoConstraints = false
        view.isUserInteractionEnabled = true
        view.leadingAnchor.constraint(equalTo: cell.contentView.leadingAnchor).isActive = true
        view.trailingAnchor.constraint(equalTo: cell.contentView.trailingAnchor).isActive = true
        view.topAnchor.constraint(equalTo:cell.contentView.topAnchor).isActive = true
        view.bottomAnchor.constraint(equalTo: cell.contentView.bottomAnchor ).isActive = true
    }
    
    //MARK:- 사용자 혹은 타인의 프로필 조회시 발생하는 구별기능
    func viewUserProfile(_ backButton: UIButton, _ fixProfileButton: UIButton, _ profileName: UILabel, _ profileImageView: UIImageView, _ stackView: UIStackView,
                         completion : @escaping () -> Void) {
        guard let currentUID = CurrentUID.shread.currentUID else { return }
        
        if !firstMyView.yourUID.isEmpty, !secondMyview.yourUID.isEmpty {
            backButton.isHidden = false
            fixProfileButton.isUserInteractionEnabled = false
            fixProfileButton.isHidden = true
            
            userRef
                .document("\(firstMyView.yourUID)")
                .getDocument() { userData, error in
                    
                    if let error = error { print("profileLoadError! \(error.localizedDescription)") }
                    
                    guard let userData = userData?.data() else { return }
                    let userThumbnail = userData["profileImageURL"] as? String ?? ""
                    let nickName = userData["nickName"] as? String ?? ""
                    
                    profileName.text = nickName
                    profileImageView.sd_setImage(with: URL(string: userThumbnail))
            }
            
            postRef.order(by: firstMyView.yourUID).getDocuments { [weak self] query, error in
                guard let self = self else { return  }
                if let error = error { print("\(error.localizedDescription)") }
                if query?.isEmpty == true {
                    completion()
                } else {
                    guard let query = query?.documents else { return }
                    
                    for document in query {
                        let dataID = document.documentID
                        let viewurl = Firestore.firestore().viewCount(dataID)
                        let likeurl = Firestore.firestore().goodMark(dataID)
                        likeurl.document(dataID).getDocument { myCheck, error in
                            likeurl.getDocuments { likeCount, error in
                                viewurl.getDocuments { viewCheck, error in
                                    Posts.cleanData(query.count,
                                                    document.data() as? [String:[String:Any]],
                                                    dataID,
                                                    userRef,
                                                    viewurl,
                                                    likeurl,
                                                    currentUID,
                                                    myCheck,
                                                    likeCount,
                                                    viewCheck) { posts in
                                                        self.firstMyView.myPosts.append(posts)
                                                        if self.firstMyView.myPosts.count == query.count {
                                                            self.secondMyview.yourData = self.firstMyView.myPosts
                                                            if let mypostCountLabel = stackView.arrangedSubviews[0] as? UILabel {
                                                                mypostCountLabel.text = "\(query.count)"
                                                            }
                                                            completion()
                                                        }
                                    }
                                }
                            }
                        }
                    }
                }
            }
        } else {
            for i in 0..<FirebaseServices.shread.myPostData.count {
                if FirebaseServices.shread.myPostData[i].userUID == currentUID {
                    firstMyView.myPosts.append(FirebaseServices.shread.myPostData[i])
                    if i == (FirebaseServices.shread.myPostData.count - 1) {
                        secondMyview.yourData =  firstMyView.myPosts
                        if let followCountLabel = stackView.arrangedSubviews[0] as? UILabel {
                            followCountLabel.text = "\(firstMyView.myPosts.count)"
                        }
                        
                    }
                }else {
                    continue
                }
            }
            
            myData = FirebaseServices.shread.myProfile
            
            FirebaseServices.shread.getChatRoomLists {
                self.thirdMyView.chatModel = FirebaseServices.shread.chatModel
            }
            
            guard let myprofileData = FirebaseServices.shread.myProfile else { return }
            
            profileName.text = myprofileData.nickName
            profileImageView.sd_setImage(with: URL(string: myprofileData.profileImageURL))
            completion()
        }
    }
    
    func checkFollow() {
        guard let currentUID = CurrentUID.shread.currentUID else { return }
        let secondUID = secondMyview.yourUID
        let followingRef = Firestore.firestore().followingRef(currentUID).document(secondUID)
        followingRef
            .getDocument { snapshot, error in
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
