//
//  LoginViewController.swift
//  Messenger
//
//  Created by Ajin on 16/02/24.
//

import UIKit
import FirebaseAuth
import FacebookLogin
import GoogleSignIn
import FirebaseCore
import SVProgressHUD

class LoginViewController: UIViewController {
    
    private let scrollView: UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.clipsToBounds = true
        return scrollView
    }()
    
    private let imageView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(named: "logo")
        imageView.contentMode = .scaleAspectFit
        return imageView
    }()

    private var emailField: UITextField = {
        let field = UITextField()
        return field
    }()

    private var passwordField: UITextField = {
        let field = UITextField()
        return field
    }()
    
    private let loginButton: UIButton = {
        let button = UIButton()
        button.setTitle("Log In", for: .normal)
        button.backgroundColor = .link
        button.setTitleColor(.white, for: .normal)
        button.layer.cornerRadius = 12
        button.titleLabel?.font = .systemFont(ofSize: 20, weight: .bold)
        return button
    }()
    
    private let fbloginButton: FBLoginButton = {
        let button = FBLoginButton()
        button.permissions = ["public_profile", "email"]
        return button
    }()
    
    private let GidSignInButton: GIDSignInButton = {
        let button = GIDSignInButton()
        return button
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        setupView()
        fbloginButton.delegate = self
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        scrollView.frame = view.bounds
        let size = scrollView.width/3
        imageView.frame = CGRect(x: (scrollView.width - size)/2,
                                 y: 100,
                                 width: size,
                                 height: size)
        emailField.frame = CGRect(x: 30,
                                  y: imageView.bottom + 10,
                                  width: scrollView.width - 60,
                                 height: 52)
        passwordField.frame = CGRect(x: 30,
                                     y: emailField.bottom + 10,
                                     width: scrollView.width - 60,
                                     height: 52)
        loginButton.frame = CGRect(x: 30,
                                   y: passwordField.bottom + 10,
                                   width: scrollView.width - 60,
                                   height: 52)
        fbloginButton.frame = CGRect(x: 30,
                                     y: loginButton.bottom + 10,
                                     width: scrollView.width - 60,
                                     height: 52)
        GidSignInButton.frame = CGRect(x: 30,
                                     y: fbloginButton.bottom + 10,
                                     width: scrollView.width - 60,
                                     height: 52)
    }
    
    func setupView(){
        title = "Log In"
        view.backgroundColor = .white
        view.addSubview(scrollView)
        scrollView.addSubview(imageView)
        emailField = createTextField(for: .emailTextField)
        scrollView.addSubview(emailField)
        passwordField = createTextField(for: .passwordTextField)
        emailField.delegate = self
        passwordField.delegate = self
        scrollView.addSubview(passwordField)
        scrollView.addSubview(loginButton)
        scrollView.addSubview(fbloginButton)
        scrollView.addSubview(GidSignInButton)
        loginButton.addTarget(self,
                              action: #selector(loginButtonTapped),
                              for: .touchUpInside)
        GidSignInButton.addTarget(self,
                                  action: #selector(googleSignInTapped),
                                  for: .touchUpInside)
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Register",
                                                            style: .done,
                                                            target: self,
                                                            action: #selector(didTapRegister))
        SVProgressHUD.setDefaultStyle(.dark)
    }
    
    @objc private func loginButtonTapped(){
        emailField.resignFirstResponder()
        passwordField.resignFirstResponder()
        guard let email = emailField.text, let password = passwordField.text, !email.isEmpty, !password.isEmpty, password.count >= 6 else {
            createAlert(title: "Failed", message: "Please enter the credentials!!")
            return
        }
        SVProgressHUD.show()
        Auth.auth().signIn(withEmail: email, password: password) { [weak self] authResult, error in
            guard let self = self else { return }
            DispatchQueue.main.async {
                SVProgressHUD.dismiss()
            }
            guard let _ = authResult, error == nil else{
                print("Error")
                return
            }
            print("Logged in")
            self.navigationController?.dismiss(animated: true)
        }
        
    }
    
    @objc private func didTapRegister(){
        let vc = RegisterViewController()
        vc.title = "Create Account"
        navigationController?.pushViewController(vc, animated: true)
    }
    
    @objc private func googleSignInTapped(){
        guard let clientId = FirebaseApp.app()?.options.clientID else {
            print("Error in client id")
            return
        }
        let config = GIDConfiguration(clientID: clientId)
        GIDSignIn.sharedInstance.configuration = config
        
        GIDSignIn.sharedInstance.signIn(withPresenting: self) { [weak self] result, error in
            guard let self = self else {
                print("Error in signin")
                return
            }
            guard let user = result?.user, let idToken = user.idToken?.tokenString else {
                print("error in result")
                return
            }
            
            let credential = GoogleAuthProvider.credential(withIDToken: idToken,
                                                           accessToken: user.accessToken.tokenString)
            guard let email = user.profile?.email, let name = user.profile?.name, let lastname = user.profile?.familyName else {
                print("Error in profile")
                return
            }
            DatabaseManager.shared.userExists(with: email) { exists in
                if !exists{
                    Auth.auth().signIn(with: credential) { authResult, error in
                        DatabaseManager.shared.insertUser(with: ChatAppUser(firstName: name,
                                                                            lastName: lastname,
                                                                            email: email))
                    }
                }
            }
            self.navigationController?.dismiss(animated: true)
        }
    }
    
    //custom views
    func createAlert(title: String, message: String){
        let alert = UIAlertController(title: title,
                                      message: message,
                                      preferredStyle: .alert)
        let dismiss = UIAlertAction(title: "Dismiss",
                                    style: .cancel)
        alert.addAction(dismiss)
        present(alert, animated: true)
    }
    
    private func createTextField(for fieldType: InputFieldType) -> UITextField{
        let field = UITextField()
        field.autocapitalizationType = .none
        field.autocorrectionType = .no
        field.layer.cornerRadius = 12
        field.layer.borderWidth = 1
        field.layer.borderColor = UIColor.lightGray.cgColor
        field.leftView = UIView(frame: CGRect(x: 0, y: 0, width: 5, height: 0))
        field.leftViewMode = .always
        field.backgroundColor = .white
        switch fieldType{
        case .emailTextField:
            field.returnKeyType = .continue
            field.placeholder = "Email Address.."
        case .passwordTextField:
            field.returnKeyType = .done
            field.placeholder = "Password.."
            field.isSecureTextEntry = true
        }
        return field
    }
    
    private enum InputFieldType{
        case emailTextField
        case passwordTextField
    }
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}

extension LoginViewController : UITextFieldDelegate{
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if textField == emailField{
            passwordField.becomeFirstResponder()
        }else if textField == passwordField{
            loginButtonTapped()
        }
        return true
    }
}

extension LoginViewController: LoginButtonDelegate{
    func loginButtonDidLogOut(_ loginButton: FBSDKLoginKit.FBLoginButton) {
        // intentially
    }
    
    func loginButton(_ loginButton: FBSDKLoginKit.FBLoginButton, didCompleteWith result: FBSDKLoginKit.LoginManagerLoginResult?, error: Error?) {
        guard let token = result?.token?.tokenString else{
            print("User authentication failed with FB")
            return
        }
        
        let credential = FacebookAuthProvider.credential(withAccessToken: token)
        Auth.auth().signIn(with: credential) { [weak self] authResult, error in
            guard let self = self else { return }
            guard let _ = authResult, error == nil else{
                print("User authentication failed with FB MFA needed")
                return
            }
            Profile.loadCurrentProfile { profile, error in
                guard let profile = profile, error == nil else {
                    print("Error in loading profile")
                    return
                }
                guard let email = profile.email else{
                    print("Error in email ")
                    return
                }
                guard let firstname = profile.firstName else{
                    print("Error in firstname ")
                    return
                }
                guard let lastname = profile.lastName else{
                    print("Error in firstname ")
                    return
                }
                DatabaseManager.shared.userExists(with: email) { exists in
                    if !exists{
                        DatabaseManager.shared.insertUser(with: ChatAppUser(firstName: firstname,
                                                                            lastName: lastname,
                                                                            email: email))
                    }
                }
            }
            self.navigationController?.dismiss(animated: true)
        }
    }
}

