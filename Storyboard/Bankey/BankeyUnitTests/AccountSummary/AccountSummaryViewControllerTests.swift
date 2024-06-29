//
//  AccountSummaryViewControllerTests.swift
//  BankeyUnitTests
//
//  Created by Ajin on 01/05/24.
//

import Foundation
import XCTest

@testable import Bankey

class AccountSummaryViewControllerTests: XCTestCase{
    var vc: AccountSummaryViewController!
    var mockManager: MockProfileManager!
    
    class MockProfileManager: ProfileManageable{
        var profile: Profile?
        var error: NetworkingError?
        
        func fetchProfile(forUserId: String, completion: @escaping (Result<Profile, NetworkingError>) -> Void) {
            if error != nil{
                completion(.failure(error!))
                return
            }
            profile = Profile(id: "1", firstName: "FirstName", lastName: "LastName")
            completion(.success(profile!))
        }
    }
    
    override func setUp() {
        super.setUp()
        vc = AccountSummaryViewController()
        mockManager = MockProfileManager()
        vc.profileManager = mockManager
//        vc.loadViewIfNeeded()
    }
    
    func testTitleAndMessageForServerError() throws {
        let titleAndMessage = vc.titleAndMessageForTesting(for: .serverError)
        XCTAssertEqual("Server Error", titleAndMessage.0)
        XCTAssertEqual("Ensure your are connected to the internet. Please try again", titleAndMessage.1)
    }
    
    func testTitleAndMessageForNetworkError() throws {
        let titleAndMessage = vc.titleAndMessageForTesting(for: .decodingError)
        XCTAssertEqual("Decoding Error", titleAndMessage.0)
        XCTAssertEqual("We could not process your request. Please try again", titleAndMessage.1)
    }
    
    func testAlertForServerError() throws{
        mockManager.error = NetworkingError.serverError
        vc.forceFetchProfile(userId: "1")
        
        XCTAssertEqual("Server Error", vc.errorAlert.title)
        XCTAssertEqual("Ensure your are connected to the internet. Please try again", vc.errorAlert.message)
    }
}
