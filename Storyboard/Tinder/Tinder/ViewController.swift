//
//  ViewController.swift
//  Tinder
//
//  Created by Ajin on 11/02/24.
//

import UIKit

class ViewController: UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        reloadScreen()
    }

    func createView() -> UIView{
        let cardView = UIView(frame: CGRect(x: 0,
                                         y: 0,
                                            width: self.view.bounds.width - 50,
                                            height: self.view.bounds.height - 150))
        cardView.backgroundColor = .blue
        cardView.layer.cornerRadius = 20
        return cardView
    }
    
    func reloadScreen(){
        let card = createView()
        card.center = view.center
        view.addSubview(card)
        let gestureRecogniser = UIPanGestureRecognizer(target: self, action: #selector(wasDragged(uiGestureRecogniser:)))
        card.addGestureRecognizer(gestureRecogniser)
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
                self.reloadScreen()
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
