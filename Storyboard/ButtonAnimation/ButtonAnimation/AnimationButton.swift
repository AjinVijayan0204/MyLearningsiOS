//
//  AnimationButton.swift
//  ButtonAnimation
//
//  Created by Ajin on 09/01/24.
//

import Foundation
import UIKit

class AnimationButton: UIButton{
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        setupView(title: "Button")
    }
    
    init(title: String){
        super.init(frame: .zero)
        
        setupView(title: title)
    }
    
    func setupView(title: String){
        translatesAutoresizingMaskIntoConstraints = false
        self.layer.cornerRadius = 12
        backgroundColor = .blue
        setTitle(title, for: .normal)
        titleLabel?.font = UIFont.systemFont(ofSize: 20, weight: .bold)
        
        self.widthAnchor.constraint(equalToConstant: 150).isActive = true
        self.heightAnchor.constraint(equalToConstant: 80).isActive = true
        
        addTarget(self, action: #selector(buttonAction), for: .touchDown)
    }
    
    @objc func buttonAction(){
        UIView.animate(withDuration: 0.1, delay: 0, usingSpringWithDamping: 0.3, initialSpringVelocity: 0.1) {
            self.transform = CGAffineTransform(scaleX: 0.95, y: 0.95)
        } completion: { completed in
            if completed{
                self.transform = .identity
            }
        }

    }
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
