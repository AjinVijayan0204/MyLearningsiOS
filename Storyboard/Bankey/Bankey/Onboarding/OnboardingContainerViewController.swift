//
//  OnboardingContainerViewController.swift
//  Bankey
//
//  Created by Ajin on 30/03/24.
//

import UIKit

protocol OnboardingContainerViewControllerDelegate: AnyObject{
    func didFinshOnboarding()
}

class OnboardingContainerViewController: UIViewController{
    
    let pageViewController: UIPageViewController
    var pages = [UIViewController]()
    
    var currentVC: UIViewController{
        didSet{
            guard let index = pages.firstIndex(of: currentVC) else { return }
            nextBtn.isHidden = index == pages.count - 1
            backBtn.isHidden = index == 0
            doneBtn.isHidden = !(index == pages.count - 1)
        }
    }
    
    let nextBtn = UIButton(type: .system)
    let backBtn = UIButton(type: .system)
    let closeBtn = UIButton(type: .system)
    let doneBtn = UIButton(type: .system)
    
    weak var delegate: OnboardingContainerViewControllerDelegate?
    
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
        
        setup()
        style()
        layout()
        
    }
}

extension OnboardingContainerViewController{
    
    private func setup(){
        view.backgroundColor = .systemPurple
        
        addChild(pageViewController)
        view.addSubview(pageViewController.view)
        pageViewController.didMove(toParent: self)
        
        view.addSubview(closeBtn)
        view.addSubview(backBtn)
        view.addSubview(nextBtn)
        view.addSubview(doneBtn)
        
        pageViewController.dataSource = self
        pageViewController.setViewControllers([pages.first!],
                                              direction: .forward,
                                              animated: false)
        currentVC = pages.first!
    }
    
    private func style(){
        
        pageViewController.view.translatesAutoresizingMaskIntoConstraints = false
        
        closeBtn.translatesAutoresizingMaskIntoConstraints = false
        closeBtn.setTitle("Close", for: [])
        closeBtn.addTarget(self, action: #selector(closeBtnTapped), for: .primaryActionTriggered)
        
        nextBtn.translatesAutoresizingMaskIntoConstraints = false
        nextBtn.setTitle("Next", for: [])
        nextBtn.addTarget(self, action: #selector(nextBtnTapped), for: .primaryActionTriggered)
        
        backBtn.translatesAutoresizingMaskIntoConstraints = false
        backBtn.setTitle("Back", for: [])
        backBtn.addTarget(self, action: #selector(backBtnTapped), for: .primaryActionTriggered)
        
        doneBtn.translatesAutoresizingMaskIntoConstraints = false
        doneBtn.setTitle("Done", for: [])
        doneBtn.addTarget(self, action: #selector(doneBtnTapped), for: .primaryActionTriggered)
    }
    
    private func layout(){
        
        //Next button
        NSLayoutConstraint.activate([
            view.trailingAnchor.constraint(equalToSystemSpacingAfter: nextBtn.trailingAnchor, multiplier: 2),
            view.bottomAnchor.constraint(equalToSystemSpacingBelow: nextBtn.bottomAnchor, multiplier: 4)
        ])
        
        //Back button
        NSLayoutConstraint.activate([
            backBtn.leadingAnchor.constraint(equalToSystemSpacingAfter: view.leadingAnchor, multiplier: 2),
            view.bottomAnchor.constraint(equalToSystemSpacingBelow: backBtn.bottomAnchor, multiplier: 4)
        ])
        
        //close button
        NSLayoutConstraint.activate([
            closeBtn.leadingAnchor.constraint(equalToSystemSpacingAfter: view.leadingAnchor, multiplier: 2),
            closeBtn.topAnchor.constraint(equalToSystemSpacingBelow: view.safeAreaLayoutGuide.topAnchor, multiplier: 2)
        ])
        
        //Done button
        NSLayoutConstraint.activate([
            view.trailingAnchor.constraint(equalToSystemSpacingAfter: doneBtn.trailingAnchor, multiplier: 2),
            view.bottomAnchor.constraint(equalToSystemSpacingBelow: doneBtn.bottomAnchor, multiplier: 4)
        ])
        
        //pageview controller
        NSLayoutConstraint.activate([
            view.topAnchor.constraint(equalTo: pageViewController.view.topAnchor),
            view.leadingAnchor.constraint(equalTo: pageViewController.view.leadingAnchor),
            view.trailingAnchor.constraint(equalTo: pageViewController.view.trailingAnchor),
            view.bottomAnchor.constraint(equalTo: pageViewController.view.bottomAnchor)
        ])
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

//MARK: - Actions
extension OnboardingContainerViewController{
    @objc func closeBtnTapped(_ sender: UIButton){
        delegate?.didFinshOnboarding()
    }
    
    @objc func nextBtnTapped(_ sender: UIButton){
        guard let nextVC = getNextViewController(from: currentVC) else { return }
        pageViewController.setViewControllers([nextVC],
                                              direction: .forward,
                                              animated: true)
    }
    
    @objc func backBtnTapped(_ sender: UIButton){
        guard let previousVC = getPreviousViewController(from: currentVC) else { return }
        pageViewController.setViewControllers([previousVC],
                                              direction: .reverse,
                                              animated: true)
    }
    
    @objc func doneBtnTapped(_ sender: UIButton){
        delegate?.didFinshOnboarding()
    }
}
