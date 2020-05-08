//
//  PhothAurhorizationService.swift
//  MakeFairytale
//
//  Created by ByungHoon Ann on 2020/04/30.
//  Copyright © 2020 ByungHoon Ann. All rights reserved.
//

import UIKit
import Photos
protocol PhothAurhorizationStatus {
    func phothAurhorizationStatus()
}

extension PhothAurhorizationStatus where Self:AlbumViewController {
    func phothAurhorizationStatus() {
        let phothAurhorizationStatus = PHPhotoLibrary.authorizationStatus()
        switch phothAurhorizationStatus {
        case .authorized:
            print("ok")
            self.requestImageCollection()
        case .denied:
            print("denied")
            
        case .notDetermined:
            print("notDetermined")
            PHPhotoLibrary.requestAuthorization { [weak self] status in
                guard let self = self else { return }
                switch status {
                case .authorized:
                    print("사용자 허용")
                    self.requestImageCollection()
                    DispatchQueue.main.async {
                        self.collectionView.reloadData()
                    }
                case .denied:
                    print("허용되지 않음")
                default: break
                }
            }
            
        case .restricted:
            let alert = UIAlertController(title: "안내",
                                          message: "동의 진행 중입니다.",
                                          preferredStyle: .alert)
            let cancelAction = UIAlertAction(title: "확인",
                                             style: .default)
            alert.addAction(cancelAction)
            present(alert, animated: true)
        @unknown default:
            print("fatal error")
        }
    }
     
}
