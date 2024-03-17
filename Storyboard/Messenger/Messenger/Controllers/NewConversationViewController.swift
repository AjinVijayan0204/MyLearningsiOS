//
//  NewConversationViewController.swift
//  Messenger
//
//  Created by Ajin on 27/02/24.
//

import UIKit
import SVProgressHUD

class NewConversationViewController: UIViewController {

    public var completion: ((SearchResult) -> (Void))?
    private var users = [[String: String]]()
    private var results = [SearchResult]()
    private var hasFetched = false
    
    //MARK: - Components
    private let searchbar:UISearchBar = {
        let searchbar = UISearchBar()
        searchbar.placeholder = "Search user"
        return searchbar
    }()
    
    private let tableView: UITableView = {
        let table = UITableView()
        table.register(NewConversationCell.self, forCellReuseIdentifier: NewConversationCell.identifier)
        table.isHidden = true
        return table
    }()
    
    private let noResultsLabel: UILabel = {
        let label = UILabel()
        label.text = "No Results"
        label.textAlignment = .center
        label.textColor = .green
        label.isHidden = true
        label.font = .systemFont(ofSize: 21, weight: .medium)
        return label
    }()
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        view.addSubview(noResultsLabel)
        view.addSubview(tableView)
        tableView.delegate = self
        tableView.dataSource = self
        view.backgroundColor = .systemBackground
        searchbar.delegate = self
        navigationController?.navigationBar.topItem?.titleView = searchbar
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Cancel",
                                                            style: .done,
                                                            target: self,
                                                            action: #selector(dismissSelf))
        searchbar.becomeFirstResponder()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        tableView.frame = view.bounds
        noResultsLabel.frame = CGRect(x: view.width/4, y: (view.height-200)/2, width: view.width/2, height: 100)
    }
    
    @objc private func dismissSelf(){
        dismiss(animated: true)
    }
}

extension NewConversationViewController: UITableViewDelegate, UITableViewDataSource{
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return results.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let model = results[indexPath.row]
        let cell = tableView.dequeueReusableCell(withIdentifier: NewConversationCell.identifier, for: indexPath) as! NewConversationCell
        cell.configure(with: model)
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        //move to next screen
        let targetUserData = results[indexPath.row]
        dismiss(animated: true) { [weak self] in
            self?.completion?(targetUserData)
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 90
    }
    
}
extension NewConversationViewController: UISearchBarDelegate{
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        guard let text = searchBar.text, !text.replacingOccurrences(of: " ", with: "").isEmpty else{
            return
        }
        searchBar.resignFirstResponder()
        results.removeAll()
        SVProgressHUD.show()
        searchUsers(query: text)
    }
    
    func searchUsers(query: String){
        if hasFetched{
            filterUsers(with: query)
        }else{
            DatabaseManager.shared.getAllUsers { [weak self] result in
                switch result{
                case .success(let usersCollection):
                    self?.hasFetched = true
                    self?.users = usersCollection
                    self?.filterUsers(with: query)
                case .failure(let error):
                    print("Failed to get user : \(error)")
                }
            }
        }
    }
    
    func filterUsers(with term: String){
        print("inside filter")
        guard let currentUserEmail = UserDefaults.standard.value(forKey: "email") as? String,
              hasFetched else{
            return
        }
        print("email found")
        let safeEmail = DatabaseManager.getSafeEmail(email: currentUserEmail)
        SVProgressHUD.dismiss()
        let results: [SearchResult] = users.filter { data in
            guard let email = data["email"],
                  email != safeEmail else{
                return false
            }
            guard let name = data["name"]?.lowercased() else{
                return false
            }
            return name.hasPrefix(term.lowercased())
        }.compactMap { dict in
            guard let email = dict["email"],
                  let name = dict["name"] else{
                return nil
            }
            return SearchResult(name: name, email: email)
        }
        self.results = results
        UpdateUI()
    }
    
    func UpdateUI(){
        if results.isEmpty{
            noResultsLabel.isHidden = false
            tableView.isHidden = true
        }else{
            noResultsLabel.isHidden = true
            tableView.isHidden = false
            tableView.reloadData()
        }
    }
}

