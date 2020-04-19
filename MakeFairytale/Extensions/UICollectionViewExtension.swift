//
//  UICollectionViewExtension.swift
//  MakeFairytale
//
//  Created by ByungHoon Ann on 2020/04/19.
//  Copyright © 2020 ByungHoon Ann. All rights reserved.
//

import UIKit
extension UICollectionView {
    func registerCell<Cell: UICollectionViewCell>(_: Cell.Type)  {
        if let nib = Cell.nib {
            self.register(nib, forCellWithReuseIdentifier: Cell.reuseIdentifier)
        } else {
            self.register(Cell.self, forCellWithReuseIdentifier: Cell.reuseIdentifier)
        }
    }
    
    func dequeueCell<Cell: UICollectionViewCell>(indexPath: IndexPath) -> Cell   {
        return self.dequeueReusableCell(withReuseIdentifier: Cell.reuseIdentifier, for: indexPath) as! Cell
    }
    
}
extension UICollectionViewCell: Reusable { }



//MARK:- HeaderView only
/*
 protocol HasElementKind {
     static var elementKind: String { get }
 }
 func dequeueView<View: UICollectionReusableView>(ofKind: String, indexPath: IndexPath) -> View where View: Reusable & HasElementKind {
     return self.dequeueReusableSupplementaryView(ofKind: ofKind, withReuseIdentifier: View.reuseIdentifier, for: indexPath) as! View
 }
 
 func registerView<View: UICollectionReusableView>(_: View.Type) where View: Reusable & HasElementKind {
     if let nib = View.nib {
         self.register(nib, forSupplementaryViewOfKind: View.elementKind, withReuseIdentifier: View.reuseIdentifier)
     } else {
         self.register(View.self, forSupplementaryViewOfKind: View.elementKind, withReuseIdentifier: View.reuseIdentifier)
     }
 }
 */
