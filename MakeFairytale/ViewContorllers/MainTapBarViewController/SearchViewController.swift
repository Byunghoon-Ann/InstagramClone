//
//  SearchViewController.swift
//  MakeFairytale
//
//  Created by ByungHoon Ann on 04/10/2019.
//  Copyright © 2019 ByungHoon Ann. All rights reserved.

import Foundation
import UIKit
class SearchViewController : UIViewController ,UISearchBarDelegate{
    
    @IBOutlet weak var festaPostLoadIndicator: UIActivityIndicatorView!
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var searchCollectionView: UICollectionView!
    
    var searchImageArray: [Posts] = [] {
        didSet {
            searchImageArray.sort { firstItem, secondItem in
                let firstDate = dateFomatter.date(from: firstItem.postDate) ?? self.today
                let secondDate = dateFomatter.date(from: secondItem.postDate) ?? self.today
                
                if  firstDate > secondDate {
                    return true
                } else {
                    return false
                }
            }
            filterData = searchImageArray
        }
    }
    var filterData: [Posts] = []
    
    lazy var dateFomatter = DateCalculation.shread.dateFomatter
    lazy var today = Today.shread.today
    
    override func viewDidLoad() {
        super.viewDidLoad()

        searchCollectionView.isHidden = true
        searchBar.searchTextField.backgroundColor = .white
        searchBar.barTintColor = .systemOrange
        festaPostLoadIndicator.startAnimating()
        
        FirebaseServices.shread.loadSearchFeedPost { [weak self] in
            guard let self = self else { return }
            self.searchImageArray = FirebaseServices.shread.posts
            self.filterData = self.searchImageArray
            self.searchCollectionView.reloadData()
            self.searchCollectionView.isHidden = false
            self.festaPostLoadIndicator.stopAnimating()
            self.festaPostLoadIndicator.isHidden = true
        }
        
        searchBar.delegate = self
        searchCollectionView.delegate = self
        searchCollectionView.dataSource = self
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        filterData = searchText.isEmpty ? searchImageArray : searchImageArray.filter { (item: Posts) -> Bool in
            return item.userComment.range(of: searchText,
                                          options: .caseInsensitive,
                                          range: nil,locale: nil) != nil
        }
        searchCollectionView.reloadData()
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        view.endEditing(true)
    }
    
    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
        searchBar.becomeFirstResponder()
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        searchBar.showsCancelButton = false
        searchBar.text = ""
        searchBar.resignFirstResponder()
    }
}

extension SearchViewController : UICollectionViewDataSource ,UICollectionViewDelegate{
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return filterData.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard indexPath.item < filterData.count else { return UICollectionViewCell() }
        let cell:SearchCell = collectionView.dequeueCell(indexPath: indexPath)
        if filterData.count == 0 {
            return cell
        } else {
            cell.searchImageView.sd_setImage(with: URL(string: filterData[indexPath.row].userPostImage[0]))
            return cell
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard let vc = UIStoryboard.viewPostingVC() else { return }
        vc.post = searchImageArray[indexPath.row]
        navigationController?.pushViewController(vc, animated: true)
    }
    
}

extension SearchViewController:  UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: view.frame.maxX/3 - 2, height: view.frame.maxY/6 - 2)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: 1, left:1, bottom: 1, right: 1 )
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 2
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 1
    }
}
