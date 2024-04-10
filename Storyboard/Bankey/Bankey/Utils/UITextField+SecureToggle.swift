//
//  UITextFieldSecureToggle.swift
//  Bankey
//
//  Created by Ajin on 10/04/24.
//

import UIKit

let passwordToggleButton = UIButton(type: .custom)

extension UITextField{
    
    func enablePasswordToggle(){
        passwordToggleButton.setImage(UIImage(systemName: "eye.fill"), for: .normal)
        passwordToggleButton.setImage(UIImage(systemName:"eye.slash.fill"), for: .selected)
        passwordToggleButton.addTarget(self, action: #selector(togglePasswordView), for: .touchUpInside)
        passwordToggleButton.tintColor = .black
        rightView = passwordToggleButton
        rightViewMode = .always
    }
    
    @objc func togglePasswordView(){
        isSecureTextEntry.toggle()
        passwordToggleButton.isSelected.toggle()
    }
}
