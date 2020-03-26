//
//  DropDownButton.swift
//  MakeFairytale
//
//  Created by ByungHoon Ann on 2020/03/25.
//  Copyright © 2020 ByungHoon Ann. All rights reserved.
//

import UIKit
protocol DropDownButtonDelegate {
    func dropdownButtonIsSelected(_ isSelected: Bool)
    func didSelectedDropDownView(_ path: Int)
}

class DropDownButton: UIButton, DropDownViewDelegate {
    var dropView = DropDownView()
    var delegate: DropDownButtonDelegate?
    var height = NSLayoutConstraint()
    var isOpen = false
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        self.backgroundColor = .clear
        
        dropView = DropDownView.init(frame: CGRect.init(x: 0, y: 0, width: 0, height: 0))
        dropView.delegate = self
        dropView.translatesAutoresizingMaskIntoConstraints = false
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func didMoveToSuperview() {
        self.superview?.addSubview(dropView)
        self.superview?.bringSubviewToFront(dropView)
        dropView.topAnchor.constraint(equalTo: self.bottomAnchor).isActive = true
        dropView.centerXAnchor.constraint(equalTo: self.centerXAnchor).isActive = true
        dropView.widthAnchor.constraint(equalToConstant: 100).isActive = true
        height = dropView.heightAnchor.constraint(equalToConstant: 0)
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        
        if isOpen == false {
            
            isOpen = true
            self.isSelected = isOpen
            NSLayoutConstraint.deactivate([self.height])
            
            if self.dropView.tableView.contentSize.height > 250 {
                self.height.constant = 250
            } else {
                self.height.constant = self.dropView.tableView.contentSize.height
            }
            
            NSLayoutConstraint.activate([self.height])
            
            UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 0.5, initialSpringVelocity: 0.5, options: .curveEaseInOut, animations: {
                self.dropView.layoutIfNeeded()
                self.dropView.center.y += self.dropView.frame.height / 2
                self.dropView.tableView.reloadData()
            }, completion: nil)
            
        } else {
            isOpen = false
            self.isSelected = isOpen
            NSLayoutConstraint.deactivate([self.height])
            self.height.constant = 0
            NSLayoutConstraint.activate([self.height])
            UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 0.5, initialSpringVelocity: 0.5, options: .curveEaseInOut, animations: {
                self.dropView.center.y -= self.dropView.frame.height / 2
                self.dropView.layoutIfNeeded()
            }, completion: nil)
            
        }
        self.delegate?.dropdownButtonIsSelected(self.isSelected)
    }
    
    func dismissDropDown() {
        isOpen = false
        NSLayoutConstraint.deactivate([self.height])
        self.height.constant = 0
        NSLayoutConstraint.activate([self.height])
        UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 0.5, initialSpringVelocity: 0.5, options: .curveEaseInOut, animations: {
            self.dropView.center.y -= self.dropView.frame.height / 2
            self.dropView.layoutIfNeeded()
        }, completion: nil)
    }
    
    //MARK:- DropDownView Delegate
    func dropDownPressed(indexPath: Int) {
        self.delegate?.didSelectedDropDownView(indexPath)
        self.delegate?.dropdownButtonIsSelected(false)
        self.dismissDropDown()
    }
}

