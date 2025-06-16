//
//  QuestionViewControllerTests.swift
//  QuizAppTests
//
//  Created by Ajin on 15/06/25.
//

import Foundation
import XCTest
@testable import QuizApp

class QuestionViewControllerTests: XCTestCase {
    
    func test_ViewDidLoadRendersQuestionHeaderText() {
        XCTAssertEqual(makeSUT(question: "Q1", options: []).headerLabel.text, "Q1")
    }
    
    func test_viewDidLoadRendersOptions() {
        var sut = makeSUT()
        XCTAssertEqual(sut.tableView.numberOfRows(inSection: 0), 0)
        sut = makeSUT(options: ["A1"])
        XCTAssertEqual(sut.tableView.numberOfRows(inSection: 0), 1)
        sut = makeSUT(options: ["A1", "A2"])
        XCTAssertEqual(sut.tableView.numberOfRows(inSection: 0), 2)
    }
    
    func test_viewDidLoadWOptionsRendersOneOptionText() {
       
        var sut = makeSUT(options: ["A1"])
        XCTAssertEqual(sut.tableView.title(at: 0), "A1")
        sut = makeSUT(options: ["A1", "A2"])
        XCTAssertEqual(sut.tableView.title(at: 0), "A1")
        XCTAssertEqual(sut.tableView.title(at: 1), "A2")
    }
    
    func test_optionSeletedNotifiesDelegate() {
        let receivedAnser = ""
        let sut = makeSUT(options: ["A1"])
    }
    func makeSUT(question: String = "", options: [String] = []) -> QuestionViewController {
        let sut = QuestionViewController(question: question, options: options)
        _ = sut.view
        return sut
    }
}

extension UITableView {
    func cell(at row: Int) -> UITableViewCell? {
        return dataSource?.tableView(self, cellForRowAt: IndexPath(row: row, section: 0))
    }
    
    func title(at row: Int) -> String? {
        return cell(at: row)?.textLabel?.text
    }
}

