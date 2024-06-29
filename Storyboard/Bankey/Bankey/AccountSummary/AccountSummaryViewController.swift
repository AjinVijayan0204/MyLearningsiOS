//
//  AccountSummaryViewController.swift
//  Bankey
//
//  Created by Ajin on 01/04/24.
//

import UIKit

class AccountSummaryViewController: UIViewController {
    
    //request models
    var profile: Profile?
    var accounts: [Account] = []
    
    //View models
    var headerViewModel = AccountSummaryHeaderView.ViewModel(welcomeMessage: "Welcome", name: "", date: Date())
    var accountCellViewModels: [AccountSummaryCell.ViewModel] = []
    
    //components
    var tableView = UITableView()
    let headerView = AccountSummaryHeaderView(frame: .zero)
    let refreshControl = UIRefreshControl()
    
    //Networking
    var profileManager: ProfileManageable = ProfileManager()
    var isLoaded = false
    
    //alert
    var errorAlert: UIAlertController = {
        let alert = UIAlertController(title: "", message: "", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Ok", style: .default))
        return alert
    }()
    
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
    }
}

extension AccountSummaryViewController{
    
    private func setup(){
        setupTableView()
        setupTableHeaderView()
        setupNavigationBar()
        setupRefreshControl()
        setupSkeletions()
        fetchData()
    }
    
    private func setupTableView(){
        tableView.backgroundColor = appColor
        tableView.dataSource = self
        tableView.delegate = self
        
        tableView.register(AccountSummaryCell.self,
                           forCellReuseIdentifier: AccountSummaryCell.reuseID)
        tableView.register(SkeletonCell.self, forCellReuseIdentifier: SkeletonCell.reuseID)
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
        
        var size = headerView.systemLayoutSizeFitting(UIView.layoutFittingCompressedSize)
        size.width = self.view.bounds.width
        headerView.frame.size = size
        
        tableView.tableHeaderView = headerView
    }
    
    private func setupNavigationBar(){
        navigationItem.rightBarButtonItem = logoutBarButtonItem
    }
    
    private func setupRefreshControl(){
        refreshControl.tintColor = appColor
        refreshControl.addTarget(self, action: #selector(refreshContent), for: .valueChanged)
        tableView.refreshControl = refreshControl
    }
    
    private func setupSkeletions(){
        let row = Account.makeSkeletion()
        accounts = Array(repeating: row, count: 10)
        
        configureTableCells(with: accounts)
    }
}

extension AccountSummaryViewController: UITableViewDataSource, UITableViewDelegate{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return accountCellViewModels.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard !accountCellViewModels.isEmpty else { return UITableViewCell()}
        
        let account = accountCellViewModels[indexPath.row]
        
        if isLoaded{
            let cell = tableView.dequeueReusableCell(withIdentifier: AccountSummaryCell.reuseID,
                                                     for: indexPath) as! AccountSummaryCell
            cell.configure(with: account)
            return cell
        }
        
        let cell = tableView.dequeueReusableCell(withIdentifier: SkeletonCell.reuseID,
                                                 for: indexPath) as! SkeletonCell
        return cell
    }
    
}

//MARK: - Networking

extension AccountSummaryViewController{
    
    private func fetchData(){
        let group = DispatchGroup()
        
        //testing with random number
        let userId = String(Int.random(in: 1..<4))
        
        fetchProfile(group: group, userId: userId)
        fetchAccounts(group: group, userId: userId)
        
        group.notify(queue: .main) {
            self.reloadView()
        }
    }
    
    private func fetchProfile(group: DispatchGroup, userId: String){
        group.enter()
        profileManager.fetchProfile(forUserId: userId) { result in
            switch result{
            case .success(let profile):
                self.profile = profile
            case .failure(let error):
                self.displayError(error)
            }
            group.leave()
        }
    }
    
    private func fetchAccounts(group: DispatchGroup, userId: String){
        group.enter()
        fetchAccounts(forUserId: userId) { result in
            switch result{
            case .success(let accounts):
                self.accounts = accounts
            case .failure(let error):
                self.displayError(error)
            }
            group.leave()
        }
    }
    
    private func reloadView(){
        self.tableView.refreshControl?.endRefreshing()
        guard let profile = self.profile else { return }
        
        self.isLoaded = true
        self.configureTableViewHeaderView(with: profile)
        self.configureTableCells(with: self.accounts)
        self.tableView.reloadData()
    }
    
    private func configureTableViewHeaderView(with profile: Profile){
        let vm = AccountSummaryHeaderView.ViewModel(welcomeMessage: "Good Morning", name: profile.firstName, date: Date())
        headerView.configure(viewModel: vm)
    }
    
    private func configureTableCells(with accounts: [Account]){
        accountCellViewModels = accounts.map({ account in
            AccountSummaryCell.ViewModel(accountType: account.type, accountName: account.name, balance: account.amount)
        })
    }
    
    private func displayError(_ error: NetworkingError){
        let titleAndMessage = titleAndMessage(for: error)
        self.showErrorAlert(title: titleAndMessage.0, message: titleAndMessage.1)
    }
    
    private func titleAndMessage(for error: NetworkingError) -> (String, String){
        let title: String
        let message: String
        switch error{
        case .serverError:
            title = "Server Error"
            message = "Ensure your are connected to the internet. Please try again"
        case .decodingError:
            title = "Decoding Error"
            message = "We could not process your request. Please try again"
        }
        return (title, message)
    }
    
    //"Network Error", "Please check your message connectivity and try again."
    private func showErrorAlert(title: String, message: String){
        /*
        let alert = UIAlertController(title: title,
                                      message: message,
                                      preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Ok", style: .default))
         */
        errorAlert.title = title
        errorAlert.message = message
        present(errorAlert, animated: true)
    }
}

//MARK: - Actions
extension AccountSummaryViewController{
    @objc func logoutTapped(_ sender: UIButton){
        NotificationCenter.default.post(name: .logout, object: nil)
    }
    
    @objc func refreshContent(){
        reset()
        setupSkeletions()
        tableView.reloadData()
        fetchData()
    }
    
    private func reset(){
        profile = nil
        accounts = []
        isLoaded = false
    }
}


//MARK: - Unit testing
extension AccountSummaryViewController{
    func titleAndMessageForTesting(for error: NetworkingError) -> (String, String){
        return titleAndMessage(for: error)
    }
    
    func forceFetchProfile(userId: String){
        fetchProfile(group: DispatchGroup(), userId: userId)
    }
}
