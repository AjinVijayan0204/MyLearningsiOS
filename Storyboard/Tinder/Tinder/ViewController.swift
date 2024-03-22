//
//  ViewController.swift
//  Tinder
//
//  Created by Ajin on 11/02/24.
//

import UIKit

protocol SwipeActionDelegate: NSObject{
    func rightSwipeAction()
    func leftswipeAction()
}

class ViewController: UIViewController {
    
    public var delegate: SwipeActionDelegate?
    
    private var isLiked: Bool = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        setupView()
    }
    
    private func createCardView() -> UIView{
        let card = UIView()
        card.backgroundColor = .blue
        card.layer.cornerRadius = 20
        return card
    }
    
    func setupView(){
        let cardView = createCardView()
        cardView.frame = CGRect(x: 0,
                                y: 0,
                                   width: self.view.bounds.width - 50,
                                   height: self.view.bounds.height - 150)
        cardView.center = self.view.center
        view.addSubview(cardView)
        
        let imageView = createImageView(with: UIImage(systemName: "person.circle.fill")!, in: cardView)
        cardView.addSubview(imageView)
        let gestureRecogniser = UIPanGestureRecognizer(target: self, action: #selector(createDragAnimation(uiGestureRecogniser:)))
        cardView.addGestureRecognizer(gestureRecogniser)
    }
    
    func createImageView(with image: UIImage, in view: UIView) -> UIImageView{
        let imgView = UIImageView(frame: CGRect(x: 0, y: 0, width: view.bounds.width - 50, height: view.bounds.height/2))
        imgView.image = image
        imgView.frame.origin = CGPoint(x: 25, y: 20)
        imgView.layer.borderColor = UIColor.black.cgColor
        imgView.layer.borderWidth = 5
        return imgView
    }
    
    @objc func createDragAnimation(uiGestureRecogniser: UIPanGestureRecognizer){
        guard let labelview = uiGestureRecogniser.view else { return }
        let translationInX = round((uiGestureRecogniser.translation(in: labelview).x * 1000)/1000)
        let transform = CGAffineTransform(rotationAngle: (translationInX/100) * 45 * (.pi/180))
        if translationInX < 0{
            addConstraints(for: labelview, anchorAt: .bottomLeading)
            isLiked = false
        }else{
            addConstraints(for: labelview, anchorAt: .bottomTrailing)
            isLiked = true
        }
        labelview.transform = transform
        if abs(translationInX * .pi/180) > 0.8 && uiGestureRecogniser.state == .ended{
            UIView.animate(withDuration: 1) {
                labelview.alpha = 0
            } completion: { [weak self] _ in
                
                guard let strongSelf = self else{
                    return
                }
                strongSelf.isLiked ? strongSelf.delegate?.rightSwipeAction() : strongSelf.delegate?.leftswipeAction()
                strongSelf.setupView()
            }
        }
    }
    
    @objc func wasDragged(uiGestureRecogniser: UIPanGestureRecognizer){
        guard let labelview = uiGestureRecogniser.view else { return }
        let translationInX = uiGestureRecogniser.translation(in: labelview).x
        let transform = CGAffineTransform(rotationAngle: (translationInX/100) * 45 * (.pi/180))
        if translationInX < 0{
            addConstraints(for: labelview, anchorAt: .bottomLeading)
        }else{
            addConstraints(for: labelview, anchorAt: .bottomTrailing)
        }
        labelview.transform = transform
        if abs(translationInX * .pi/180) > 0.8{
            UIView.animate(withDuration: 1) {
                labelview.alpha = 0
            }
            if uiGestureRecogniser.state == .ended{
               // self.reloadScreen()
            }
        }
    }
    
    func addConstraints(for childView: UIView, anchorAt type: AnchoringModes){
        var multiplier: Double = 0
        switch type{
        case .bottomLeading:
            multiplier = -1
        case .bottomTrailing:
            multiplier = 1
        }
        childView.anchorPoint = type.getAnchor()
        childView.center = CGPoint(x: view.center.x + multiplier * childView.bounds.width/2, y: view.center.y + childView.bounds.height/2)
        
    }
    
    enum AnchoringModes{
        case bottomLeading
        case bottomTrailing
    }
   
}

extension ViewController.AnchoringModes{
    func getAnchor() -> CGPoint{
        switch self{
        case .bottomLeading:
            return CGPoint(x: 0, y: 1)
        case .bottomTrailing:
            return CGPoint(x: 1, y: 1)
        }
    }
}
