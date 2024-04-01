//
//  MainViewController.swift
//  Bankey
//
//  Created by Ajin on 01/04/24.
//

import UIKit

class MainViewController: UITabBarController{
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupViews()
        setupTabBar()
    }
    
    private func setupViews(){
        let summaryVC = AccountSummaryViewController()
        let moneyVC = MoveMoneyViewController()
        let moreVC = MoreViewController()
        
        summaryVC.setTabBarImage(imageName: "list.dash.header.rectangle", title: "Summary")
        moneyVC.setTabBarImage(imageName: "arrow.left.arrow.right", title: "Move Money")
        moreVC.setTabBarImage(imageName: "ellipsis.circle", title: "More")
        
        let summaryNC = UINavigationController(rootViewController: summaryVC)
        let moneyNC = UINavigationController(rootViewController: moneyVC)
        let moreNC = UINavigationController(rootViewController: moreVC)
        
        summaryNC.navigationBar.barTintColor = appColor
        //hideNavigationBarLine(summaryNC.navigationBar)
        
        let tabBarLists = [summaryNC, moneyNC, moreNC]
        viewControllers = tabBarLists
    }
    
    private func setupTabBar(){
        tabBar.isTranslucent = false
    }
    
    private func hideNavigationBarLine(_ navigationBar: UINavigationBar){
        let img = UIImage()
        navigationBar.shadowImage = img
        navigationBar.setBackgroundImage(img, for: .default)
        navigationBar.isTranslucent = false
    }
}

class MoveMoneyViewController: UIViewController{
    override func viewDidLoad() {
        view.backgroundColor = .systemOrange
    }
}

class MoreViewController: UIViewController{
    override func viewDidLoad() {
        view.backgroundColor = .systemPurple
    }
}
