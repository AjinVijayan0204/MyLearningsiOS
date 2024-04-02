//
//  AccountSummaryViewController.swift
//  Bankey
//
//  Created by Ajin on 01/04/24.
//

import UIKit

class AccountSummaryViewController: UIViewController {

    var accounts: [AccountSummaryCell.ViewModel] = []
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
        fetchData()
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
        return accounts.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard !accounts.isEmpty else { return UITableViewCell()}
        
        let cell = tableView.dequeueReusableCell(withIdentifier: AccountSummaryCell.reuseID,
                                                 for: indexPath) as! AccountSummaryCell
        let account = accounts[indexPath.row]
        cell.configure(with: account)
        
        return cell
    }
    
}

extension AccountSummaryViewController{
    private func fetchData(){
        let savings = AccountSummaryCell.ViewModel(accountType: .Banking,
                                                   accountName: "Basic Savings")
        let visa = AccountSummaryCell.ViewModel(accountType: .CreditCard,
                                                accountName: "Visa Avion Card")
        let investment = AccountSummaryCell.ViewModel(accountType: .Investment,
                                                      accountName: "Tax-Free Saver")
        
        accounts.append(savings)
        accounts.append(visa)
        accounts.append(investment)
    }
}
