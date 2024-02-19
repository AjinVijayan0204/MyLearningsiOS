//
//  RegisterViewController.swift
//  Messenger
//
//  Created by Ajin on 18/02/24.
//

import UIKit

class RegisterViewController: UIViewController {
    
    private let scrollView: UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.clipsToBounds = true
        scrollView.isUserInteractionEnabled = true
        return scrollView
    }()
    
    private let imageView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(systemName: "person")
        imageView.tintColor = .gray
        imageView.contentMode = .scaleAspectFit
        imageView.isUserInteractionEnabled = true
        return imageView
    }()

    private var firstnameField: UITextField = {
        let field = UITextField()
        return field
    }()
    
    private var lastnameField: UITextField = {
        let field = UITextField()
        return field
    }()
    
    private var emailField: UITextField = {
        let field = UITextField()
        return field
    }()

    private var passwordField: UITextField = {
        let field = UITextField()
        return field
    }()
    
    private let RegisterButton: UIButton = {
        let button = UIButton()
        button.setTitle("Register", for: .normal)
        button.backgroundColor = .systemGreen
        button.setTitleColor(.white, for: .normal)
        button.layer.cornerRadius = 12
        button.titleLabel?.font = .systemFont(ofSize: 20, weight: .bold)
        return button
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        setupView()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        scrollView.frame = view.bounds
        let size = scrollView.width/3
        imageView.frame = CGRect(x: (scrollView.width - size)/2,
                                 y: 100,
                                 width: size,
                                 height: size)
        firstnameField.frame = CGRect(x: 30,
                                  y: imageView.bottom + 10,
                                  width: scrollView.width - 60,
                                 height: 52)
        lastnameField.frame = CGRect(x: 30,
                                  y: firstnameField.bottom + 10,
                                  width: scrollView.width - 60,
                                 height: 52)
        emailField.frame = CGRect(x: 30,
                                  y: lastnameField.bottom + 10,
                                  width: scrollView.width - 60,
                                 height: 52)
        passwordField.frame = CGRect(x: 30,
                                     y: emailField.bottom + 10,
                                     width: scrollView.width - 60,
                                     height: 52)
        RegisterButton.frame = CGRect(x: 30,
                                   y: passwordField.bottom + 10,
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
        scrollView.addSubview(passwordField)
        scrollView.addSubview(RegisterButton)
        firstnameField = createTextField(for: .firstnameField)
        scrollView.addSubview(firstnameField)
        lastnameField = createTextField(for: .lastnameField)
        scrollView.addSubview(lastnameField)
        emailField.delegate = self
        passwordField.delegate = self
        
        let gesture = UITapGestureRecognizer(target: self, action: #selector(didTapChangeProfilePic))
        gesture.numberOfTouchesRequired = 1
        imageView.addGestureRecognizer(gesture)
        
        RegisterButton.addTarget(self,
                              action: #selector(loginButtonTapped),
                              for: .touchUpInside)
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Register",
                                                            style: .done,
                                                            target: self,
                                                            action: #selector(didTapRegister))
        
    }
    
    @objc private func didTapChangeProfilePic(){
        print("image icon")
    }
    
    @objc private func loginButtonTapped(){
        emailField.resignFirstResponder()
        passwordField.resignFirstResponder()
        guard let firstname = firstnameField.text,
              let lastname = lastnameField.text,
              let email = emailField.text,
              let password = passwordField.text,
              !firstname.isEmpty,
              !lastname.isEmpty,
              !email.isEmpty,
              !password.isEmpty,
              password.count >= 6 else {
            createAlert(title: "Failed", message: "Please enter the user data to create account!!")
            return
        }
        
        
    }
    
    @objc private func didTapRegister(){
        let vc = RegisterViewController()
        vc.title = "Create Account"
        navigationController?.pushViewController(vc, animated: true)
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
        case .firstnameField:
            field.returnKeyType = .continue
            field.placeholder = "First Name.."
        case .lastnameField:
            field.returnKeyType = .continue
            field.placeholder = "Last Name.."
        case .passwordTextField:
            field.returnKeyType = .done
            field.placeholder = "Password.."
            field.isSecureTextEntry = true
        }
        return field
    }
    
    private enum InputFieldType{
        case firstnameField
        case lastnameField
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

extension RegisterViewController : UITextFieldDelegate{
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if textField == emailField{
            passwordField.becomeFirstResponder()
        }else if textField == passwordField{
            loginButtonTapped()
        }
        return true
    }
}
