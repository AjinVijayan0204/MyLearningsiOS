//
//  ProfileTests.swift
//  BankeyUnitTests
//
//  Created by Ajin on 12/04/24.
//

import Foundation
import XCTest

@testable import Bankey

class ProfileTests: XCTestCase{
    
    override class func setUp() {
        super.setUp()
        
    }
    
    func testCanParse(){
        let json = """
            {
            "id": "1",
            "first_name": "Kevin",
            "last_name": "Flynn"
            }
            """
        let data = json.data(using: .utf8)!
        let result = try! JSONDecoder().decode(Profile.self, from: data)
        
        XCTAssertEqual(result.id, "1")
        XCTAssertEqual(result.firstName, "Kevin")
        XCTAssertEqual(result.lastName, "Flynn")
    }
}
