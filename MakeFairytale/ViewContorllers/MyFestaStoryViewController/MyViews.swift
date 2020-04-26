//
//  MyViews.swift
//  MakeFairytale
//
//  Created by ByungHoon Ann on 2019/10/16.
//  Copyright © 2019 ByungHoon Ann. All rights reserved.
//

//MARK:TapBarViewController 5번째(row = 4)탭, 안의 넣을 View 앱이용자 본인의 포스팅 모음 CollcectionView
//MARK: section 0 
import Foundation
import UIKit
import SDWebImage
import Firebase

fileprivate let currentUID = Auth.auth().currentUser?.uid
protocol MyViewsDelegate : class {
    func customMyPostDidselect(_ path: Int)
}

class MyViews : UIView {
    
    weak var delegate : MyViewsDelegate?
    var firstAlertLabel : UILabel = {
          let label = UILabel()
          label.translatesAutoresizingMaskIntoConstraints = false
          label.numberOfLines = 0
          label.font = .boldSystemFont(ofSize: 20)
          label.textColor = .black
          label.text = "게시물이 존재하지 않습니다."
          label.textAlignment = .center
          return label
       }()
    
    override init(frame: CGRect) {
        super.init(frame:frame)
        self.backgroundColor = .white
        firstAlertLabel.isHidden = true
        self.addSubview(firstAlertLabel)
        firstAlertLabel.centerXAnchor.constraint(equalTo: self.centerXAnchor).isActive = true
        firstAlertLabel.centerYAnchor.constraint(equalTo: self.centerYAnchor).isActive = true
        setUpCustomMyPosts()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    var collectionView : UICollectionView = {
        let collectionLayout = UICollectionViewFlowLayout()
        collectionLayout.scrollDirection = .vertical
        let collectionView = UICollectionView(frame: CGRect(x: 0, y: 0, width: 0, height: 0), collectionViewLayout: collectionLayout)
        
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        return collectionView
    }()
    
    var myPosts: [Posts] = [] {
        willSet {
            self.myPosts.removeAll()
        }
        didSet {
            collectionView.reloadData()
        }
    }
    var myUID : String = ""
    var yourUID : String = ""
    func customCollection() {
        
        collectionView.delegate = self
        collectionView.dataSource = self
        
        collectionView.backgroundColor = .white
        collectionView.register(UINib(nibName:"MyViewsCollectionCell",bundle: nil), forCellWithReuseIdentifier: "MyViewsCollectionCell")
    }
    
    var indicatorViewLeadingConstraint:NSLayoutConstraint!
    var indicatorViewWidthConstraint: NSLayoutConstraint!
    
    func setUpCustomMyPosts() {
        customCollection()
        self.addSubview(collectionView)
        collectionView.leadingAnchor.constraint(equalTo: self.leadingAnchor).isActive = true
        collectionView.widthAnchor.constraint(equalTo: self.widthAnchor).isActive = true
        collectionView.trailingAnchor.constraint(equalTo: self.trailingAnchor).isActive = true
        collectionView.heightAnchor.constraint(equalTo: self.heightAnchor).isActive = true
        collectionView.topAnchor.constraint(equalTo: self.topAnchor).isActive = true
        collectionView.bottomAnchor.constraint(equalTo: self.bottomAnchor).isActive = true
    }
}

extension MyViews : UICollectionViewDataSource,UICollectionViewDelegate,UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if !yourUID.isEmpty {
                if myPosts.isEmpty {
                    print("myposts is empty1")
                    firstAlertLabel.isHidden = false
                    collectionView.isHidden = true
                    return 0
                }else {
                    print("myposts is empty2")
                    collectionView.isHidden = false
                    firstAlertLabel.isHidden = true
                    return myPosts.count
                }
            } else {
                if myPosts.isEmpty {
                    print("myposts is empty3")
                    firstAlertLabel.isHidden = false
                    collectionView.isHidden = true
                    return 0
                }else {
                    print("myposts is empty4")
                    firstAlertLabel.isHidden = true
                    collectionView.isHidden = false
                    return myPosts.count
                }
            }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard indexPath.item < myPosts.count else { return UICollectionViewCell() }
        let cell:MyViewsCollectionCell = collectionView.dequeueCell(indexPath: indexPath)      
        cell.imageView.sd_setImage(with: URL(string: myPosts[indexPath.row].userPostImage[0]))
        return cell
    }
   
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: collectionView.frame.width/3 - 1, height: collectionView.frame.width/3 - 1)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        delegate?.customMyPostDidselect(indexPath.row)
    }
}


