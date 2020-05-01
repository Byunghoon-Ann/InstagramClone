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
    let today = Today.shread.today
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
            recentNotification(alertData.alertDate, calendar)
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        userThumbnail.layer.cornerRadius = userThumbnail.frame.height/2
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        userThumbnail.layer.borderWidth = 0
    }
    
    func recentNotification(_ date: String, _ calendar: Calendar) {
        let _date = dateFomatter.string(from: today)
        let _today = dateFomatter.date(from: _date) ?? today
        let _postDate = dateFomatter.date(from: date) ?? today
        let calendarC = calendar.dateComponents([.year,.month,.day,.hour,.minute,.second],from:_postDate,to: _today)
        
        if case let (y?, m?, d? ,h?, mi?, s?) = (calendarC.year,calendarC.month,calendarC.day,calendarC.hour ,calendarC.minute,calendarC.second) {
            if y == 0, m == 0, d == 0, h <= 2, mi <= 60,  s >= 0 {
                userThumbnail.layer.borderColor = UIColor.systemRed.cgColor
                userThumbnail.layer.borderWidth = 2.0
            }
        }
    }
}
