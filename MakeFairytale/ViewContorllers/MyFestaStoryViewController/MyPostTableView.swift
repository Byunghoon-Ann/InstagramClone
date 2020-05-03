//
//  MyPostTableView.swift
//  MakeFairytale
//
//  Created by ByungHoon Ann on 2019/10/23.
//  Copyright © 2019 ByungHoon Ann. All rights reserved.
//
//MARK: section 1
import UIKit
import SDWebImage

protocol MyPostTableViewDelegate : class {
    func customMyPostTableDidselect(_ path: Int)
}

class MyPostTableView: UIView {

    weak var delegate : MyPostTableViewDelegate?
    
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
    
    var tableView : UITableView = {
        let tableView = UITableView(frame: CGRect(x: 0, y: 0, width: 0, height: 0))
        tableView.translatesAutoresizingMaskIntoConstraints = false
        return tableView
    }()
    
    var yourData : [Posts] = [] {
        willSet {
            self.yourData.removeAll()
        }
        didSet {
            tableView.reloadData()
        }
    }
    
    var yourUID: String {
        return CurrentUID.shread.yourUID
    }
    
    func customCollection() {
        tableView.delegate = self
        tableView.dataSource = self
        
        tableView.backgroundColor = .white
        tableView.registerCell(MyPostTableViewCell.self)
    }
    
    func setUpCustomMyPosts() {
        customCollection()
        self.addSubview(tableView)
        tableView.leadingAnchor.constraint(equalTo: self.leadingAnchor).isActive = true
        tableView.widthAnchor.constraint(equalTo: self.widthAnchor).isActive = true
        tableView.trailingAnchor.constraint(equalTo: self.trailingAnchor).isActive = true
        tableView.heightAnchor.constraint(equalTo: self.heightAnchor).isActive = true
        tableView.topAnchor.constraint(equalTo: self.topAnchor).isActive = true
        tableView.bottomAnchor.constraint(equalTo: self.bottomAnchor).isActive = true
    }
}

extension MyPostTableView : UITableViewDelegate,UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        guard yourData.count > 0 else {
            firstAlertLabel.isHidden = false
            tableView.isHidden = true
            return 0 }
        firstAlertLabel.isHidden = true
        tableView.isHidden = false
        return yourData.count
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell:MyPostTableViewCell = tableView.dequeueCell(indexPath: indexPath)
        cell.postData = yourData[indexPath.row]
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        delegate?.customMyPostTableDidselect(indexPath.row)
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        guard let tableCellHeight = AnimationControl.shread.tableCellHeight else { return 500 }
        return tableCellHeight
    }
}

