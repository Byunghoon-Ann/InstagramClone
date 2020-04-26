//
//  NotificationAlertTableCell.swift
//  MakeFairytale
//
//  Created by ByungHoon Ann on 2020/02/11.
//  Copyright © 2020 ByungHoon Ann. All rights reserved.
//

import UIKit

class NotificationAlertTableCell: UITableViewCell {
    @IBOutlet weak var userThumbnail: UIImageView!
    @IBOutlet weak var alertDate: UILabel!
    @IBOutlet weak var alertContents: UILabel!
    
    lazy var dateFomatter : DateFormatter = {
        let dateFomatter = DateFormatter()
        dateFomatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        dateFomatter.locale = Locale(identifier: "kr_KR")
        return dateFomatter
    }()
    
    let appDelegate = UIApplication.shared.delegate as! AppDelegate
    let today = Date()
    let calendar = Calendar(identifier: .gregorian)
    var alertsData: NotificationData? {
        didSet {
            guard let alertData = alertsData else { return }
            alertDate.text = DateCalculation.shread.requestDate(alertData.alertDate,
                                                                           dateFomatter,
                                                                           Today.shread.today,
                                                                           calendar)
            if alertData.userThumbnail == "" {
                userThumbnail.image = UIImage(named: "userSelected@40x40")
            }
            userThumbnail.sd_setImage(with: URL(string: alertData.userThumbnail))
            alertContents.text = alertData.alertContent
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        userThumbnail.layer.cornerRadius = userThumbnail.frame.height/2
    }

}
