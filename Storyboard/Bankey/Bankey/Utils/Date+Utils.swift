//
//  Date+Utils.swift
//  Bankey
//
//  Created by Ajin on 11/04/24.
//

import Foundation

extension Date{
    
    static var bankKeyDateFormatter: DateFormatter{
        let formatter = DateFormatter()
        formatter.timeZone = TimeZone(identifier: "IST")
        return formatter
    }
    
    var monthDayYearString: String{
        let formatter = Date.bankKeyDateFormatter
        formatter.dateFormat = "MMM d, yyyy"
        return formatter.string(from: self)
    }
}
