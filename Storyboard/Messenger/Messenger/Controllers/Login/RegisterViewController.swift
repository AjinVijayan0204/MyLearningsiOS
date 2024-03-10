//
//  RegisterViewController.swift
//  Messenger
//
//  Created by Ajin on 18/02/24.
//

import UIKit
import FirebaseAuth
import SVProgressHUD

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
        imageView.layer.borderWidth = 1
        imageView.layer.borderColor = UIColor.black.cgColor
        imageView.layer.cornerRadius = imageView.bounds.width / 2
        imageView.layer.masksToBounds = true
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
        title = "Register"
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
        /*navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Register",
                                                            style: .done,
                                                            target: self,
                                                            action: #selector(didTapRegister))
         */
        
    }
    
    @objc private func didTapChangeProfilePic(){
        presentPhotoActionSheet()
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
        
        SVProgressHUD.show()
        
        DatabaseManager.shared.userExists(with: email) { [weak self]exists in
            guard let self = self else { return }
            DispatchQueue.main.async {
                SVProgressHUD.dismiss()
            }
            guard !exists else{
                self.createAlert(title: "Failed", message: "Email is already used!!")
                return
            }
            Auth.auth().createUser(withEmail: email, password: password) { authResult, error in
                guard let _ = authResult, error == nil else{
                    print(error?.localizedDescription)
                    return
                }
                let chatUser = ChatAppUser(firstName: firstname,
                                           lastName: lastname,
                                           email: email)
                DatabaseManager.shared.insertUser(with: chatUser) { success in
                    print("Inside db")
                    if success{
                        //upload image
                        print("success")
                        guard let image = self.imageView.image, let data = image.pngData() else{
                            return
                        }
                        let filename = chatUser.profilePictureName
                        print(filename)
                        StorageManager.shared.uploadProfilePicture(with: data,
                                                                   filename: filename) { result in
                            switch result{
                            case .success(let downloadUrl):
                                UserDefaults.standard.set(downloadUrl, forKey: "profile_picture_url")
                                print(downloadUrl)
                            case .failure(let error):
                                print("Storage error : \(error)")
                            }
                        }
                    }
                }
                self.navigationController?.dismiss(animated: true)
            }
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

extension RegisterViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate{
    
    func presentPhotoActionSheet(){
        let actionSheet = UIAlertController(title: "Profile Picture",
                                            message: "Upload using",
                                            preferredStyle: .actionSheet)
        let cancel = UIAlertAction(title: "Cancel",
                                   style: .cancel,
                                   handler: nil)
        let takePhoto = UIAlertAction(title: "Take Photo",
                                      style: .default) { [weak self] _ in
            guard let self = self else { return }
            self.presentCamera()
        }
        let choosePhoto = UIAlertAction(title: "Choose Photo",
                                      style: .default) { [weak self] _ in
            guard let self = self else { return }
            self.presentPhotoPicker()
        }
        actionSheet.addAction(cancel)
        actionSheet.addAction(takePhoto)
        actionSheet.addAction(choosePhoto)
        present(actionSheet, animated: true)
    }
    
    func presentCamera(){
        let vc = UIImagePickerController()
        vc.sourceType = .camera
        vc.delegate = self
        vc.allowsEditing = true
        present(vc, animated: true)
    }
    
    func presentPhotoPicker(){
        let vc = UIImagePickerController()
        vc.sourceType = .photoLibrary
        vc.delegate = self
        vc.allowsEditing = true
        present(vc, animated: true)
    }
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        guard let selectedImg = info[UIImagePickerController.InfoKey.editedImage] as? UIImage else { return }
        self.imageView.image = selectedImg
        
        dismiss(animated: true)
    }
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        //
    }
    
}
