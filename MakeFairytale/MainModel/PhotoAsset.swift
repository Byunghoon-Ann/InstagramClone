//
//  PhotoAsset.swift
//  MakeFairytale
//
//  Created by ByungHoon Ann on 2020/02/10.
//  Copyright © 2020 ByungHoon Ann. All rights reserved.
//

import UIKit
import Photos

struct PhotoAsset {
    var fetchResults: PHFetchResult<PHAsset>
    var albumName: String
    var fetchCollection: PHAssetCollection
}
