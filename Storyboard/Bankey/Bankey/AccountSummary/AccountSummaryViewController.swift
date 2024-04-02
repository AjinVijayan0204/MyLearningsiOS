//
//  AccountSummaryViewController.swift
//  Bankey
//
//  Created by Ajin on 01/04/24.
//

import UIKit

class AccountSummaryViewController: UIViewController {

    let games = [ "Pacman", "Space Invaders", "Space patrol"]
    
    var tableView = UITableView()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        setup()
        style()
        layout()
    }
}

extension AccountSummaryViewController{
    
    private func setup(){
        setupTableView()
        setupTableHeaderView()
    }
    
    private func setupTableView(){
        tableView.dataSource = self
        tableView.delegate = self
    
        tableView.register(AccountSummaryCell.self,
                           forCellReuseIdentifier: AccountSummaryCell.reuseID)
        tableView.rowHeight = AccountSummaryCell.rowHeight
        tableView.tableFooterView = UIView()
        
        tableView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(tableView)
        
        NSLayoutConstraint.activate([
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.topAnchor.constraint(equalTo: view.topAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor)])
    }
    
    private func setupTableHeaderView(){
        let header = AccountSummaryHeaderView(frame: .zero)
        
        var size = header.systemLayoutSizeFitting(UIView.layoutFittingCompressedSize)
        size.width = self.view.bounds.width
        header.frame.size = size
        
        tableView.tableHeaderView = header
    }
    
    private func style(){
        
    }
    
    private func layout(){

    }
}

extension AccountSummaryViewController: UITableViewDataSource, UITableViewDelegate{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return games.count
    }
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: AccountSummaryCell.reuseID, for: indexPath) as! AccountSummaryCell
        return cell
    }
    
    
}
