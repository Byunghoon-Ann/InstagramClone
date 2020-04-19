//
//  DateFormatterExtension.swift
//  MakeFairytale
//
//  Created by ByungHoon Ann on 2020/04/19.
//  Copyright © 2020 ByungHoon Ann. All rights reserved.
//

import Foundation

extension DateFormatter {
    static let yyyyMMdd: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        formatter.locale = Locale(identifier: "kr_KR")
        formatter.calendar = Calendar(identifier: .iso8601)
        return formatter
    }()
}
