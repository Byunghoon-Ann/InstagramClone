//
//  Reusable.swift
//  MakeFairytale
//
//  Created by ByungHoon Ann on 2020/04/19.
//  Copyright © 2020 ByungHoon Ann. All rights reserved.
//
//MARK:- 출처 : https://www.youtube.com/watch?v=iDEG8ggP-lY

import UIKit

protocol Reusable {
    static var reuseIdentifier: String { get }
    static var nib: UINib? { get }
}

extension Reusable {
    static var reuseIdentifier: String {
        return String(describing: Self.self)
    }
    
    static var nib: UINib? {
        return UINib(nibName: reuseIdentifier, bundle: nil)
    }
}
