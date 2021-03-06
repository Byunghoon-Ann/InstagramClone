//
//  DateCalculation.swift
//  MakeFairytale
//
//  Created by ByungHoon Ann on 2020/04/20.
//  Copyright © 2020 ByungHoon Ann. All rights reserved.
//

import UIKit

class DateCalculation {
    static let shread = DateCalculation()
    
    let dateFomatter : DateFormatter = {
       let dateFomatter = DateFormatter()
       dateFomatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
       dateFomatter.locale = Locale(identifier: "kr_KR")
       return dateFomatter
    }()
    let calendar = Calendar(identifier: .gregorian)
    
    func requestDate(_ stringDate: String,
                                _ dateFomatter: DateFormatter,
                                _ today: Date,
                                _ calendar: Calendar) -> String {
        
        let dateString = dateFomatter.string(from: today)
        let nowToday = dateFomatter.date(from: dateString) ?? today
        let postdates = dateFomatter.date(from: stringDate) ?? today
        let calendarC = calendar.dateComponents([.year,.month,.day,.hour,.minute,.second], from: postdates,to: nowToday)
        
        if case let (y?, m?, d?, h?, mi?, s?) = (calendarC.year, calendarC.month, calendarC.day, calendarC.hour,calendarC.minute,calendarC.second) {
            if y == 0, m == 0, d == 0, h == 0, mi == 0  {
                return "\(s)초 전"
            } else if y == 0, m == 0, d == 0, h == 0, mi >= 1 {
                return "\(mi)분 전"
            } else if y == 0, m == 0, d == 0, h >= 1 {
                return "\(h)시간 전"
            }else if  y == 0, m == 0, d >= 1{
                return "\(d)일 전"
            }else if y == 0, m >= 1 {
                return "\(m)개월 전"
            }else if y >= 1, m >= 12 {
                return "\(y)년 전"
            }
        }
        return "\(today)"
    }
    
    func requestSort( _ beforeSortPosts: inout [Posts],
                      _ dateFormatter: DateFormatter,
                      _ today: Date) {
        beforeSortPosts.sort { firstItem, secondItem in
            let firstDate = dateFomatter.date(from: firstItem.postDate) ?? today
            let secondDate = dateFomatter.date(from: secondItem.postDate) ?? today
            if  firstDate > secondDate {
                return true
            } else {
                return false
            }
        }
    }
    
    func requestRepleSort( _ beforeSortPosts: inout [RepleData],
                           _ dateFormatter: DateFormatter,
                           _ today: Date) {
        beforeSortPosts.sort { firstItem, secondItem in
            let firstDate = dateFomatter.date(from: firstItem.repleDate) ?? today
            let secondDate = dateFomatter.date(from: secondItem.repleDate) ?? today
            if  firstDate < secondDate {
                return true
            } else {
                return false
            }
        }
    }
    
}
