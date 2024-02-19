//
//  ViewController.swift
//  Messenger
//
//  Created by Ajin on 16/02/24.
//

import UIKit

class ConverstaionViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        view.backgroundColor = .red
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        let isLoggesIn = UserDefaults.standard.bool(forKey: "logged_in")
        if !isLoggesIn{
            let vc = LoginViewController()
            let nav = UINavigationController(rootViewController: vc)
            nav.modalPresentationStyle = .fullScreen
            present(nav, animated: false)
        }
    }


}

