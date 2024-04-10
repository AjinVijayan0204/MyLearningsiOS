//
//  DecimalUtil.swift
//  Bankey
//
//  Created by Ajin on 02/04/24.
//

import Foundation

extension Decimal{
    var doubleValue: Double{
        return NSDecimalNumber(decimal: self).doubleValue
    }
}
