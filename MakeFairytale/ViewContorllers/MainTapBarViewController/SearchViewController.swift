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
    
    let today = Date()
    var searchImageArray: [Posts] = []
    var filterData: [Posts] = []
    lazy var dateFomatter : DateFormatter = {
        let dateFomatter = DateFormatter()
        dateFomatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        dateFomatter.locale = Locale(identifier: "kr_KR")
        return dateFomatter
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        searchCollectionView.isHidden = true
        searchBar.searchTextField.backgroundColor = .white
        searchBar.barTintColor = .systemOrange
        festaPostLoadIndicator.startAnimating()
        
        LoadFile.shread.loadSearchFeedPost {
            self.searchImageArray = LoadFile.shread.posts
            self.searchImageArray.sort { firstItem, secondItem in
                let firstDate = self.dateFomatter.date(from: firstItem.postDate) ?? self.today
                let secondDate = self.dateFomatter.date(from: secondItem.postDate) ?? self.today
                
                if  firstDate > secondDate {
                    return true
                } else {
                    return false
                }
            }
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
            return item.userComment.range(of: searchText,options: .caseInsensitive,range: nil,locale: nil) != nil
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
        
        guard let cell = searchCollectionView.dequeueReusableCell(withReuseIdentifier: "searchcell", for: indexPath) as? SearchCell else { return UICollectionViewCell()}
        if filterData.count == 0 {
            return cell
        } else {
            cell.searchImageView.sd_setImage(with: URL(string: filterData[indexPath.row].userPostImage[0]))
            return cell
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard let viewPostingVC = storyboard?.instantiateViewController(withIdentifier:"ViewPostingController") as? ViewPostingController else { return }
        viewPostingVC.post = self.searchImageArray[indexPath.row]
        navigationController?.pushViewController(viewPostingVC, animated: true)
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
