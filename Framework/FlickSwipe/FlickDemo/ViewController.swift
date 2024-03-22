//
//  ViewController.swift
//  FlickDemo
//
//  Created by Ajin on 21/03/24.
//

import UIKit
import FlickSwipe

class ViewController: FlickViewController, SwipeActionDelegate, SwipeActionDatasource{
    
    func getMoreProfiles() {
        print("get more profiles")
    }
    
    
    func rightSwipeAction() {
        print("right swiped")
    }
    
    func leftswipeAction() {
        print("left swiped")
    }
    
    var profiles: [Person] = [
        Person(name: "Person 1", age: 20, image: UIImage(named: "Person 1")!),
        Person(name: "Person 2", age: 21, image: UIImage(named: "Person 2")!),
        Person(name: "Person 3", age: 20, image: UIImage(named: "Person 3")!),
        Person(name: "Person 4", age: 20, image: UIImage(named: "Person 4")!),
        Person(name: "Person 5", age: 20, image: UIImage(named: "Person 5")!),
        Person(name: "Person 6", age: 20, image: UIImage(named: "Person 6")!)
    ]
    
    var likedProfiles: [Person] = []
    

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        actionDelegate = self
        delegate = self
    }


}

