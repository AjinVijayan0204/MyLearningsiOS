//
//  ViewController.swift
//  Bankey
//
//  Created by Ajin on 27/03/24.
//

import UIKit

protocol LogoutDelegate: AnyObject{
    func didLogout()
}

protocol LoginViewControllerDelegate: AnyObject{
    func didLogin()
}

class LoginViewController: UIViewController {

    let titleLabel = UILabel()
    let descriptionLabel = UILabel()
    let loginView = LoginView()
    let signInBtn = UIButton(type: .system)
    let errorMessageLabel = UILabel()
    
    weak var delegate: LoginViewControllerDelegate?
    
    var username: String? {
        return loginView.usernameTextField.text
    }
    var password: String? {
        return loginView.passwordTextField.text
    }
    
    //animation
    var leadingEdgesOffScreen: CGFloat = -1000
    var leadingEdgesOnScreen: CGFloat = 16
    
    var titleLeadingAnchor: NSLayoutConstraint?
    var descriptionLeadingAnchor: NSLayoutConstraint?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        style()
        layout()
    }

    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        
        signInBtn.configuration?.showsActivityIndicator = false
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        animate()
    }
}

extension LoginViewController{
    
    func style(){
        
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.textAlignment = .center
        titleLabel.textColor = .black
        titleLabel.alpha = 0
        titleLabel.font = .systemFont(ofSize: 25, weight: .bold)
        titleLabel.text = "Bankey"
        titleLabel.numberOfLines = 0
        
        descriptionLabel.translatesAutoresizingMaskIntoConstraints = false
        descriptionLabel.textAlignment = .center
        descriptionLabel.textColor = .black
        descriptionLabel.font = .systemFont(ofSize: 18, weight: .bold)
        descriptionLabel.text = "Your premium source for all things banking!"
        descriptionLabel.numberOfLines = 0
        
        loginView.translatesAutoresizingMaskIntoConstraints = false
        
        signInBtn.translatesAutoresizingMaskIntoConstraints = false
        signInBtn.configuration = .filled()
        signInBtn.configuration?.imagePadding = 8
        signInBtn.setTitle("Sign In", for: [])
        signInBtn.addTarget(self, action: #selector(signInTapped(sender:)), for: .primaryActionTriggered)
        
        errorMessageLabel.translatesAutoresizingMaskIntoConstraints = false
        errorMessageLabel.textAlignment = .center
        errorMessageLabel.textColor = .systemRed
        errorMessageLabel.numberOfLines = 0
        errorMessageLabel.isHidden = true
    }
    
    func layout(){
        
        view.addSubview(titleLabel)
        view.addSubview(descriptionLabel)
        view.addSubview(loginView)
        view.addSubview(signInBtn)
        view.addSubview(errorMessageLabel)
        
        
        //Title
        NSLayoutConstraint.activate([
            loginView.topAnchor.constraint(equalToSystemSpacingBelow: titleLabel.bottomAnchor, multiplier: 10),
            titleLabel.trailingAnchor.constraint(equalTo: loginView.trailingAnchor)
        ])
        
        titleLeadingAnchor = titleLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: leadingEdgesOffScreen)
        titleLeadingAnchor?.isActive = true
        
        // decription label constraints
        NSLayoutConstraint.activate([
            loginView.topAnchor.constraint(equalToSystemSpacingBelow: descriptionLabel.bottomAnchor, multiplier: 2),
            descriptionLabel.trailingAnchor.constraint(equalTo: titleLabel.trailingAnchor)
        ])
        descriptionLeadingAnchor = descriptionLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: leadingEdgesOffScreen)
        descriptionLeadingAnchor?.isActive = true
        
        // login view constraints
        NSLayoutConstraint.activate([
            loginView.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            loginView.leadingAnchor.constraint(equalToSystemSpacingAfter: view.leadingAnchor, multiplier: 1),
            view.trailingAnchor.constraint(equalToSystemSpacingAfter: loginView.trailingAnchor, multiplier: 1)
        ])
        
        //button constraints
        NSLayoutConstraint.activate([
            signInBtn.topAnchor.constraint(equalToSystemSpacingBelow: loginView.bottomAnchor, multiplier: 2),
            signInBtn.leadingAnchor.constraint(equalToSystemSpacingAfter: view.leadingAnchor, multiplier: 1),
            view.trailingAnchor.constraint(equalToSystemSpacingAfter: signInBtn.trailingAnchor, multiplier: 1)
        ])
        
        //error label constraints
        NSLayoutConstraint.activate([
            errorMessageLabel.topAnchor.constraint(equalToSystemSpacingBelow: signInBtn.bottomAnchor, multiplier: 2),
            errorMessageLabel.leadingAnchor.constraint(equalToSystemSpacingAfter: view.leadingAnchor, multiplier: 1),
            view.trailingAnchor.constraint(equalToSystemSpacingAfter: errorMessageLabel.trailingAnchor, multiplier: 1)
        ])
        
        
    }
}

extension LoginViewController{
    @objc func signInTapped(sender: UIButton){
        errorMessageLabel.isHidden = true
        login()
    }
    
    private func login(){
        guard let username = username, let password = password else{
            assertionFailure("Username/ password should not be nil")
            return
        }
        
        //comment for default signin
//        if username.isEmpty || password.isEmpty{
//            configureView(withMessage: "Username/ password cannot be blank")
//            return
//        }
        
        if username == "" && password == ""{
            signInBtn.configuration?.showsActivityIndicator = true
            delegate?.didLogin()
        }else{
            configureView(withMessage: "Incorrect credentials")
        }
    }
    
    private func configureView(withMessage message: String){
        errorMessageLabel.isHidden = false
        errorMessageLabel.text = message
        shakeButton()
    }
    
    private func shakeButton(){
        let animation = CAKeyframeAnimation()
        animation.keyPath = "position.x"
        animation.values = [0, 10, -10, 10, 0]
        animation.keyTimes = [0, 0.25, 0.5, 0.75, 1]
        animation.duration = 0.4
        
        animation.isAdditive = true
        signInBtn.layer.add(animation, forKey: "shake")
    }
}

//MARK: - Animations

extension LoginViewController{
    
    private func animate(){
        let duration: Double = 2
        
        let animator = UIViewPropertyAnimator(duration: duration, curve: .easeInOut){
            self.titleLeadingAnchor?.constant = self.leadingEdgesOnScreen
            self.view.layoutIfNeeded()
        }
        animator.startAnimation()
        
        let animator2 = UIViewPropertyAnimator(duration: duration, curve: .easeInOut){
            self.descriptionLeadingAnchor?.constant = self.leadingEdgesOnScreen
            self.view.layoutIfNeeded()
        }
        animator2.startAnimation(afterDelay: 1)
        
        let animator3 = UIViewPropertyAnimator(duration: duration * 2, curve: .easeInOut){
            self.titleLabel.alpha = 1
            self.descriptionLabel.alpha = 1
            self.view.layoutIfNeeded()
        }
        animator3.startAnimation(afterDelay: 1)
    }
}
