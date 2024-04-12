//
//  CurrencyFormatterTest.swift
//  BankeyUnitTests
//
//  Created by Ajin on 02/04/24.
//

import Foundation
import XCTest

@testable import Bankey

class Test: XCTestCase{
    var formatter: CurrencyFormatter!
    
    override func setUp() {
        super.setUp()
        formatter = CurrencyFormatter()
    }
    
    func testBreakDollarsIntoCents(){
        let result = formatter.breakIntoDollarsAndCents(929466.23)
        XCTAssertEqual(result.0, "929,466")
        XCTAssertEqual(result.1, "23")
    }
    
    func testDollarsFormatted(){
        let result = formatter.dollarsFormatted(929466.33)
        XCTAssertEqual(result, "$929,466.33")
    }
    
    func testZeroDollarsFormatted(){
        let locale = Locale.current
        let currencySymbol = locale.currencySymbol!
        let result = formatter.dollarsFormatted(0.00)
        XCTAssertEqual(result, "\(currencySymbol)0.00")
    }
}
