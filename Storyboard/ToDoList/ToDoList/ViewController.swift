//
//  ViewController.swift
//  ToDoList
//
//  Created by Ajin on 15/01/24.
//

import UIKit

class ViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    var items: [String] = []
    
    @IBOutlet weak var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        

    }

    override func viewDidAppear(_ animated: Bool) {
        let itemObjects = UserDefaults.standard.object(forKey: "items")
        if let tempItems = itemObjects as? [String]{
            items = tempItems
        }
        tableView.reloadData()
        print("came")
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        items.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell(style: UITableViewCell.CellStyle.default, reuseIdentifier: "Cell")
        var content = cell.defaultContentConfiguration()
        content.text = items[indexPath.row] as String
        cell.contentConfiguration = content
        return cell
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete{
            items.remove(at: indexPath.row)
            tableView.reloadData()
            UserDefaults.standard.set(items, forKey: "items")
        }
    }
    
}

