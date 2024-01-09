//
//  ViewController.swift
//  TwitterAnimationStoryboard
//
//  Created by Ajin on 09/01/24.
//

import UIKit

class ViewController: UIViewController {

    var imageView: UIImageView = {
        let imgView = UIImageView()
        imgView.isUserInteractionEnabled = true
        imgView.image = UIImage(named: "tile00")
        imgView.translatesAutoresizingMaskIntoConstraints = false
        return imgView
    }()
    var likeImages = [UIImage]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        view.addSubview(imageView)
        imageView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(animateImage)))
        imageView.widthAnchor.constraint(equalToConstant: 80).isActive = true
        imageView.widthAnchor.constraint(equalToConstant: 80).isActive = true
        imageView.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        imageView.centerYAnchor.constraint(equalTo: view.centerYAnchor).isActive = true
        
        for i in 0...28{
            likeImages.append(UIImage(named: "tile0\(i)")!)
        }
    }

    @objc func animateImage(){
        imageView.animationImages = likeImages
        imageView.animationDuration = 0.6
        imageView.animationRepeatCount = 1
        imageView.image = likeImages.last
        imageView.startAnimating()
    }

}

