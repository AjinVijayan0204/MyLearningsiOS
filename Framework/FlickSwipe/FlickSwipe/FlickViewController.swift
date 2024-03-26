//
//  FlickViewController.swift
//  FlickSwipe
//
//  Created by Ajin on 21/03/24.
//

import UIKit

public struct Person{
    let name: String
    let age: Int
    let image: UIImage
    
    public init(name: String, age: Int, image: UIImage) {
        self.name = name
        self.age = age
        self.image = image
    }
}

public protocol SwipeActionDelegate: NSObject{
    func rightSwipeAction()
    func leftswipeAction()
}

public protocol SwipeActionDatasource: NSObject{
    var profiles: [Person] {get set}
    var cardColor: UIColor? { get }
    
    func getMoreProfiles()
}

public extension SwipeActionDatasource{

    var cardColor: UIColor? { return nil }
    func getFirstProfile()-> Person?{
        guard let profile = profiles.first else {
            return nil
        }
        return profile
    }
    
    func getNextProfile()-> Person?{
        profiles.removeFirst()
        if let profile = profiles.first {
            return profile
        }else{
            getMoreProfiles()
        }
        return nil
    }
}

open class FlickViewController: UIViewController {

    public var delegate: SwipeActionDelegate!
    public var actionDelegate: SwipeActionDatasource!{
        didSet{
            if let delegate = actionDelegate, let firstProfile = delegate.getFirstProfile(){
                setupView(for: firstProfile)
            }
        }
    }
    
    private var isLiked: Bool = false
    
    open override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.

    }

    private func setupView(for person: Person){
        let cardView = createCardView()
        cardView.frame = CGRect(x: 0,
                                y: 0,
                                   width: self.view.bounds.width - 50,
                                   height: self.view.bounds.height - 150)
        cardView.center = self.view.center
        view.addSubview(cardView)
        
        let imageView = createImageView(with: person.image, in: cardView)
        cardView.addSubview(imageView)
        
        let nameLabel = createNameLabel(with: person.name, in: cardView)
        cardView.addSubview(nameLabel)
        
        let gestureRecogniser = UIPanGestureRecognizer(target: self, action: #selector(createDragAnimation(uiGestureRecogniser:)))
        cardView.addGestureRecognizer(gestureRecogniser)
    }
    
    private func createCardView() -> UIView{
        let card = UIView()
        if let bgColor = actionDelegate.cardColor{
            card.backgroundColor = bgColor
        }else{
            card.backgroundColor = UIColor(red: 0.664, green: 0.664, blue: 0.664, alpha: 1)
        }
        card.layer.cornerRadius = 20
        return card
    }
    
    private func createNameLabel(with name: String, in view: UIView)-> UILabel{
        let nameLabel = UILabel(frame: CGRect(x: 25, y: view.bounds.height/2 + 20, width: view.bounds.width - 50, height: 80))
        nameLabel.text = name
        nameLabel.font = .boldSystemFont(ofSize: 16)
        return nameLabel
    }
    
    private func Age(with age: String, in view: UIView)-> UILabel{
        let ageLabel = UILabel(frame: CGRect(x: 25, y: view.bounds.height/2 + 50, width: view.bounds.width - 50, height: 80))
        ageLabel.text = age
        ageLabel.font = .boldSystemFont(ofSize: 16)
        return ageLabel
    }
    
    private func createImageView(with image: UIImage, in view: UIView) -> UIImageView{
        let imgView = UIImageView(frame: CGRect(x: 25, y: 20, width: view.bounds.width - 50, height: view.bounds.height/2))
        imgView.image = image
        imgView.frame.origin = CGPoint(x: 25, y: 20)
        imgView.layer.borderColor = UIColor.black.cgColor
        imgView.layer.borderWidth = 5
        return imgView
    }
    
    @objc private func createDragAnimation(uiGestureRecogniser: UIPanGestureRecognizer){
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
                strongSelf.isLiked ? strongSelf.delegate.rightSwipeAction() : strongSelf.delegate.leftswipeAction()
                guard let nextPerson = strongSelf.actionDelegate.getNextProfile() else{
                    return
                }
                strongSelf.setupView(for: nextPerson)
            }
        }
    }
    
    private func addConstraints(for childView: UIView, anchorAt type: AnchoringModes){
        var multiplier: Double = 0
        switch type{
        case .bottomLeading:
            multiplier = -1
        case .bottomTrailing:
            multiplier = 1
        }
        childView.layer.anchorPoint = type.getAnchor()
        //childView.anchorPoint = type.getAnchor()
        childView.center = CGPoint(x: view.center.x + multiplier * childView.bounds.width/2, y: view.center.y + childView.bounds.height/2)
        
    }
    
    enum AnchoringModes{
        case bottomLeading
        case bottomTrailing
    }
    
}

internal extension FlickViewController.AnchoringModes{
    func getAnchor() -> CGPoint{
        switch self{
        case .bottomLeading:
            return CGPoint(x: 0, y: 1)
        case .bottomTrailing:
            return CGPoint(x: 1, y: 1)
        }
    }
}
