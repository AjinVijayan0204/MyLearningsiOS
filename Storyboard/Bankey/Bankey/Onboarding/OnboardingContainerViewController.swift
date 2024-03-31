//
//  OnboardingContainerViewController.swift
//  Bankey
//
//  Created by Ajin on 30/03/24.
//

import UIKit

class OnboardingContainerViewController: UIViewController{
    
    let pageViewController: UIPageViewController
    var pages = [UIViewController]()
    var currentVC: UIViewController{
        didSet{
            
        }
    }
    
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        pageViewController = UIPageViewController(transitionStyle: .scroll,
                                                  navigationOrientation: .horizontal)
        
        let page1 = OnboardingViewController(imageName: "delorean",
                                             titleText: "Bankey is faster, easier to use and has a brand new look and feel that will make you feel like you are back in 1989")
        let page2 = OnboardingViewController(imageName: "thumbs",
                                             titleText: "Move your money around the world quickly and securely")
        let page3 = OnboardingViewController(imageName: "world",
                                             titleText: "Learn more at www.bankey.com")
        
        pages.append(page1)
        pages.append(page2)
        pages.append(page3)
        
        currentVC = pages.first!
        
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .systemPurple
        
        addChild(pageViewController)
        view.addSubview(pageViewController.view)
        pageViewController.didMove(toParent: self)
        
        pageViewController.dataSource = self
        pageViewController.view.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            view.topAnchor.constraint(equalTo: pageViewController.view.topAnchor),
            view.leadingAnchor.constraint(equalTo: pageViewController.view.leadingAnchor),
            view.trailingAnchor.constraint(equalTo: pageViewController.view.trailingAnchor),
            view.bottomAnchor.constraint(equalTo: pageViewController.view.bottomAnchor)
        ])
        
        pageViewController.setViewControllers([pages.first!],
                                              direction: .forward,
                                              animated: false)
        currentVC = pages.first!
    }
}

//MARK: - pageview controller datasource
extension OnboardingContainerViewController: UIPageViewControllerDataSource{
    
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController? {
        return getPreviousViewController(from: viewController)
    }
    
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController? {
        return getNextViewController(from: viewController)
    }
    
    func getPreviousViewController(from viewController: UIViewController)-> UIViewController?{
        guard let index = pages.firstIndex(of: viewController), index > 0 else{
            return nil
        }
        currentVC = pages[index-1]
        return currentVC
    }
    
    func getNextViewController(from viewController: UIViewController)-> UIViewController?{
        guard let index = pages.firstIndex(of: viewController), index + 1 < pages.count else{
            return nil
        }
        currentVC = pages[index+1]
        return currentVC
    }
    
    func presentationCount(for pageViewController: UIPageViewController) -> Int {
        return pages.count
    }
    
    func presentationIndex(for pageViewController: UIPageViewController) -> Int {
        return pages.firstIndex(of: currentVC) ?? 0
    }
}

