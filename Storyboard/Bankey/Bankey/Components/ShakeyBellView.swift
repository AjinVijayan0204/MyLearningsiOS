//
//  ShakeyBellView.swift
//  Bankey
//
//  Created by Ajin on 10/04/24.
//

import Foundation
import UIKit

class ShakeyBellView: UIView{
    
    let imageView = UIImageView()
    
    let buttonView = UIButton()
    let buttonHeight: CGFloat = 13
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        setup()
        style()
        layout()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override var intrinsicContentSize: CGSize{
        return CGSize(width: 48, height: 48)
    }
}

extension ShakeyBellView{
    
    func setup(){
        let singleTap = UITapGestureRecognizer(target: self, action: #selector(imageViewTapped(_:)))
        imageView.addGestureRecognizer(singleTap)
        imageView.isUserInteractionEnabled = true
    }
    
    func style(){
        translatesAutoresizingMaskIntoConstraints = false
        
        imageView.translatesAutoresizingMaskIntoConstraints = false
        let image = UIImage(systemName: "bell.fill")?.withTintColor(.white, renderingMode: .alwaysOriginal)
        imageView.image = image
        
        buttonView.translatesAutoresizingMaskIntoConstraints = false
        buttonView.setTitle("9", for: .normal)
        buttonView.titleLabel?.font = .systemFont(ofSize: 10)
        buttonView.setTitleColor(.white, for: .normal)
        buttonView.backgroundColor = .systemRed
        buttonView.layer.cornerRadius = buttonHeight/2
        
    }
    
    func layout(){
        addSubview(imageView)
        addSubview(buttonView)
        
        //image
        NSLayoutConstraint.activate([
            imageView.centerXAnchor.constraint(equalTo: centerXAnchor),
            imageView.centerYAnchor.constraint(equalTo: centerYAnchor),
            imageView.widthAnchor.constraint(equalToConstant: 24),
            imageView.heightAnchor.constraint(equalToConstant: 24)
        ])
        
        //button
        NSLayoutConstraint.activate([
            buttonView.topAnchor.constraint(equalTo: imageView.topAnchor),
            buttonView.trailingAnchor.constraint(equalToSystemSpacingAfter: imageView.trailingAnchor, multiplier: -9),
            buttonView.widthAnchor.constraint(equalToConstant: buttonHeight),
            buttonView.heightAnchor.constraint(equalToConstant: buttonHeight)
        ])
    
    }
    
}

//MARK: - Actions
extension ShakeyBellView{
    @objc func imageViewTapped(_ recogniser: UITapGestureRecognizer){
        shakeBell(duration: 1.0, angle: .pi/8)
    }
    
    private func shakeBell(duration: Double, angle: Double){
        let numberOfFrames: Double = 6
        let frameDuration = Double(1/numberOfFrames)
        
        UIView.animateKeyframes(withDuration: duration, delay: 0) {
            UIView.addKeyframe(withRelativeStartTime: 0, relativeDuration: frameDuration) {
                self.imageView.transform = CGAffineTransform(rotationAngle: -angle)
            }
            UIView.addKeyframe(withRelativeStartTime: frameDuration, relativeDuration: frameDuration) {
                self.imageView.transform = CGAffineTransform(rotationAngle: +angle)
            }
            UIView.addKeyframe(withRelativeStartTime: frameDuration*2, relativeDuration: frameDuration) {
                self.imageView.transform = CGAffineTransform(rotationAngle: -angle)
            }
            UIView.addKeyframe(withRelativeStartTime: frameDuration*3, relativeDuration: frameDuration) {
                self.imageView.transform = CGAffineTransform(rotationAngle: +angle)
            }
            UIView.addKeyframe(withRelativeStartTime: frameDuration*4, relativeDuration: frameDuration) {
                self.imageView.transform = CGAffineTransform(rotationAngle: -angle)
            }
            UIView.addKeyframe(withRelativeStartTime: frameDuration*5, relativeDuration: frameDuration) {
                self.imageView.transform = CGAffineTransform.identity
            }
        }
    }
}
