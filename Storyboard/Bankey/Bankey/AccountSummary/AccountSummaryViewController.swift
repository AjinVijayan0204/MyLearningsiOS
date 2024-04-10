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
    
    lazy var logoutBarButtonItem: UIBarButtonItem = {
        let barBtnItem = UIBarButtonItem(title: "Logout",
                                         style: .plain,
                                         target: self,
                                         action: #selector(logoutTapped))
        barBtnItem.tintColor = .label
        return barBtnItem
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        setup()
        setupNavigationBar()
    }
    
    func setupNavigationBar(){
        navigationItem.rightBarButtonItem = logoutBarButtonItem
    }
}

extension AccountSummaryViewController{
    
    private func setup(){
        setupTableView()
        setupTableHeaderView()
        fetchData()
    }
    
    private func setupTableView(){
        tableView.backgroundColor = appColor
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
                                                   accountName: "Basic Savings",
                                                   balance: 929466.23)
        let chequing = AccountSummaryCell.ViewModel(accountType: .Banking,
                                                    accountName: "No-Fee All-In Chequing",
                                                    balance: 17562.44)
        let visa = AccountSummaryCell.ViewModel(accountType: .CreditCard,
                                                accountName: "Visa Avion Card",
                                                balance: 412.83)
        let masterCard = AccountSummaryCell.ViewModel(accountType: .CreditCard,
                                                      accountName: "Student Mastercard",
                                                      balance: 50.83)
        let investment1 = AccountSummaryCell.ViewModel(accountType: .Investment,
                                                       accountName: "Tax-Free Saver",
                                                       balance: 2000.00)
        let investment2 = AccountSummaryCell.ViewModel(accountType: .Investment,
                                                       accountName: "Growth Fund",
                                                       balance: 15000.00)
        
        accounts.append(savings)
        accounts.append(chequing)
        accounts.append(visa)
        accounts.append(masterCard)
        accounts.append(investment1)
        accounts.append(investment2)
    }
}

//MARK: - Actions

extension AccountSummaryViewController{
    @objc func logoutTapped(_ sender: UIButton){
        NotificationCenter.default.post(name: .logout, object: nil)
    }
}
