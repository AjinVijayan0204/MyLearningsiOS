//
//  ViewController.swift
//  Messenger
//
//  Created by Ajin on 16/02/24.
//

import UIKit
import FirebaseAuth
import SVProgressHUD

class ConverstaionViewController: UIViewController {

    private var conversations = [Conversation]()
    private let spinner: SVProgressHUD = {
        let spinner = SVProgressHUD()
        spinner.defaultStyle = .dark
        return spinner
    }()
    
    private let tableView: UITableView = {
        let table = UITableView()
        table.register(ConversationTableViewCell.self, forCellReuseIdentifier: ConversationTableViewCell.identifier)
        return table
    }()
    
    private let noConverstionLabel: UILabel = {
        let label = UILabel()
        label.text = "No conversation"
        label.textAlignment = .center
        label.textColor = .gray
        label.font = .systemFont(ofSize: 21, weight: .medium)
        label.isHidden = true
        return label
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        view.backgroundColor = .white
        setupView()
        startListeningForConversations()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        validateAuth()
        startListeningForConversations()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        tableView.frame = view.bounds
        noConverstionLabel.frame = CGRect(x: 10,
                                          y: (view.height - 100)/2,
                                          width: view.width - 20,
                                          height: 100)
    }

    private func setupView(){
        tableView.delegate = self
        tableView.dataSource = self
        view.addSubview(tableView)
        view.addSubview(noConverstionLabel)
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .compose,
                                                            target: self,
                                                            action: #selector(didTapComposeButton))
    }
    
    private func validateAuth(){
        if Auth.auth().currentUser == nil{
            let vc = LoginViewController()
            let nav = UINavigationController(rootViewController: vc)
            nav.modalPresentationStyle = .fullScreen
            present(nav, animated: false)
        }
    }
    
    private func startListeningForConversations(){
        guard let email = UserDefaults.standard.value(forKey: "email") as? String else{
            return
        }
        let safeEmail = DatabaseManager.getSafeEmail(email: email)
        DatabaseManager.shared.getAllConversation(for: safeEmail) { [weak self]result in
            switch result{
            case .success(let conversations):
                guard !conversations.isEmpty else{
                    self?.tableView.isHidden = true
                    self?.noConverstionLabel.isHidden = false
                    return
                }
                self?.tableView.isHidden = false
                self?.noConverstionLabel.isHidden = true
                self?.conversations = conversations
                DispatchQueue.main.async {
                    self?.tableView.reloadData()
                }
            case .failure(let error):
                self?.tableView.isHidden = true
                self?.noConverstionLabel.isHidden = false
                print("failed to get conversations: \(error)")
            }
        }
    }
    
    @objc private func didTapComposeButton(){
        let vc = NewConversationViewController()
        vc.completion = { [weak self]result in
            guard let strongSelf = self else{
                return
            }
            let currentConversations = strongSelf.conversations
            if let targetConversation = currentConversations.first(where: { conv in
                conv.otherUserEmail == DatabaseManager.getSafeEmail(email: result.email)
            }){
                let vc = ChatViewController(with: targetConversation.otherUserEmail,
                                            id: targetConversation.id)
                vc.isNewConversation = false
                vc.title = targetConversation.name
                vc.navigationItem.largeTitleDisplayMode = .never
                strongSelf.navigationController?.pushViewController(vc, animated: true)
            }else{
                strongSelf.createNewConversation(searchResult: result)
            }
        }
        let navVC = UINavigationController(rootViewController: vc)
        present(navVC, animated: true)
    }
    
    private func createNewConversation(searchResult: SearchResult){
        
        DatabaseManager.shared.conversationExists(with: searchResult.email) { [weak self] result in
            guard let self = self else{
                return
            }
            switch result{
            case .success(let conversationId):
                let vc = ChatViewController(with: searchResult.email, id: conversationId)
                vc.isNewConversation = false
                vc.title = searchResult.name
                vc.navigationItem.largeTitleDisplayMode = .never
                navigationController?.pushViewController(vc, animated: true)
            case .failure(_):
                let vc = ChatViewController(with: searchResult.email, id: nil)
                vc.isNewConversation = true
                vc.title = searchResult.name
                vc.navigationItem.largeTitleDisplayMode = .never
                navigationController?.pushViewController(vc, animated: true)
            }
        }
        
    }
}

extension ConverstaionViewController: UITableViewDelegate, UITableViewDataSource{
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return conversations.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let model = conversations[indexPath.row]
        let cell =  tableView.dequeueReusableCell(withIdentifier: ConversationTableViewCell.identifier, for: indexPath) as! ConversationTableViewCell
        cell.configure(with: model)
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let model = conversations[indexPath.row]
        openConversation(model)
        
    }
    
    func openConversation(_ model: Conversation){
        let vc = ChatViewController(with: model.otherUserEmail, id: model.id)
        vc.title = model.name
        vc.navigationItem.largeTitleDisplayMode = .never
        navigationController?.pushViewController(vc, animated: true)
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 120
    }
    
    func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath) -> UITableViewCell.EditingStyle {
        return .delete
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete{
            let convId = conversations[indexPath.row].id
            tableView.beginUpdates()
            self.conversations.remove(at: indexPath.row)
            tableView.deleteRows(at: [indexPath], with: .left)
            DatabaseManager.shared.deleteConversation(conversationId: convId) { success in
                if !success{
                    print("Failed to delete")
                }
            }
            tableView.endUpdates()
        }
    }
}
