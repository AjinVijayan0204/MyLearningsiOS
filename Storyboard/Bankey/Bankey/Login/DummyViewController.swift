//
//  DummyViewController.swift
//  Bankey
//
//  Created by Ajin on 31/03/24.
//

import UIKit

class DummyViewController: UIViewController{
    
    let stackView = UIStackView()
    let label = UILabel()
    let logoutBtn = UIButton(type: .system)
    
    weak var logoutDelegate: LogoutDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        style()
        layout()
    }
}

extension DummyViewController{
    func style(){
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.axis = .vertical
        stackView.spacing = 20
        
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "Welcome"
        label.font = .preferredFont(forTextStyle: .title1)
        
        logoutBtn.translatesAutoresizingMaskIntoConstraints = false
        logoutBtn.configuration = .filled()
        logoutBtn.setTitle("Logout", for: [])
        logoutBtn.addTarget(self, action: #selector(logout), for: .primaryActionTriggered)
    }
    
    func layout(){
        
        stackView.addArrangedSubview(label)
        stackView.addArrangedSubview(logoutBtn)
        
        view.addSubview(stackView)
        
        NSLayoutConstraint.activate([
            stackView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            stackView.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        ])
    }
}

extension DummyViewController{
    @objc func logout(_ sender: UIButton){
        logoutDelegate?.didLogout()
    }
}
