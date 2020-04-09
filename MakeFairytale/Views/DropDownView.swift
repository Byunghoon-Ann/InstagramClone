//
//  DropDownView.swift
//  MakeFairytale
//
//  Created by ByungHoon Ann on 2020/03/25.
//  Copyright © 2020 ByungHoon Ann. All rights reserved.
//
import UIKit

protocol DropDownViewDelegate {
    func dropDownPressed(indexPath : Int)
}

class DropDownView: UIView, UITableViewDelegate, UITableViewDataSource  {
    
    var dropDownOptions = ["알림","개인정보 화면","대화","로그아웃"]
    
    var tableView = UITableView()
    
    var delegate: DropDownViewDelegate?
    let appDelegate = UIApplication.shared.delegate as! AppDelegate

    override init(frame: CGRect) {
        super.init(frame: frame)
        
        tableView.backgroundColor = .white
        self.backgroundColor = .white
        self.layer.cornerRadius = 5
        tableView.delegate = self
        tableView.dataSource = self
        
        tableView.translatesAutoresizingMaskIntoConstraints = false
        
        self.addSubview(tableView)
        
        tableView.leftAnchor.constraint(equalTo: self.leftAnchor).isActive = true
        tableView.rightAnchor.constraint(equalTo: self.rightAnchor).isActive = true
        tableView.topAnchor.constraint(equalTo: self.topAnchor).isActive = true
        tableView.bottomAnchor.constraint(equalTo: self.bottomAnchor).isActive = true
        tableView.register(UINib(nibName: "DropDownCell", bundle: nil), forCellReuseIdentifier: "DropDownCell")
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return dropDownOptions.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "DropDownCell") as? DropDownCell else { return UITableViewCell()}
        cell.buttonBedge.isHidden = true
        
        if indexPath.row != 0,indexPath.row != 2, appDelegate.sideViewBadgeCheck == true {
            cell.buttonBedge.isHidden = true
        }
        
        if indexPath.row == 0, appDelegate.sideViewBadgeCheck == true {
             cell.buttonBedge.isHidden = false
        }
        
        if indexPath.row == 2, appDelegate.chattingCheck == true {
             cell.buttonBedge.isHidden = false
        }
        
        cell.textLabel?.text = dropDownOptions[indexPath.row]
        cell.textLabel?.textAlignment = .center
        cell.textLabel?.backgroundColor = .white
        cell.textLabel?.textColor = .black
        cell.textLabel?.font = .boldSystemFont(ofSize: 12)
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.delegate?.dropDownPressed(indexPath: indexPath.row)
        if indexPath.row == 0 {
            appDelegate.sideViewBadgeCheck = false
        }
        if indexPath.row == 2 {
            appDelegate.chattingCheck = false
        }
        self.tableView.deselectRow(at: indexPath, animated: true)
    }
}

class DropDownCell: UITableViewCell {
    @IBOutlet weak var buttonBedge: UIImageView!
    override func awakeFromNib() {
        super.awakeFromNib()
        self.backgroundColor = .white
        buttonBedge.layer.cornerRadius = buttonBedge.frame.height/2
    }
}
