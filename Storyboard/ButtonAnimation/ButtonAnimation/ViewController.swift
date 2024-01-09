//
//  ViewController.swift
//  ButtonAnimation
//
//  Created by Ajin on 09/01/24.
//

import UIKit

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        let button = AnimationButton(title: "Submit")
        view.addSubview(button)
        
        button.centerXAnchor.constraint(equalTo: view.centerXAnchor, constant: 0).isActive = true
        button.centerYAnchor.constraint(equalTo: view.centerYAnchor, constant: 0).isActive = true
    }


}

