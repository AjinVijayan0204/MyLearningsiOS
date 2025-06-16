//
//  QuestionViewController.swift
//  QuizApp
//
//  Created by Ajin on 15/06/25.
//

import UIKit

class QuestionViewController: UIViewController, UITableViewDataSource {

    @IBOutlet weak var headerLabel: UILabel!
    @IBOutlet weak var tableView: UITableView!
    
    private var question: String = ""
    private var options: [String] = []
    private let reusableIdentifier = "Cell"
    
    convenience init(question: String,
                     options: [String]) {
        self.init()
        self.question = question
        self.options = options
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.headerLabel.text = self.question
    }
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.options.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell()
        cell.textLabel?.text = options[indexPath.row]
        return cell
    }
    
    private func dequeueReusableCell() -> UITableViewCell {
        if let cell = tableView.dequeueReusableCell(withIdentifier: self.reusableIdentifier) {
            return cell
        }
        return UITableViewCell(style: .default, reuseIdentifier: self.reusableIdentifier)
    }
}
