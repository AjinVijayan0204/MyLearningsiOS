//
//  ViewController.swift
//  Instagram
//
//  Created by Ajin on 02/02/24.
//

import UIKit
import FirebaseCore
import FirebaseAuth
import FirebaseDatabase


class ViewController: UIViewController {

    var isLogin: Bool = false
    var ref: DatabaseReference = Database.database().reference()
    
    convenience init() {
        self.init(ref: nil)
        }
        
        init(ref: DatabaseReference?) {
            self.ref = Database.database().reference()
            super.init(nibName: nil, bundle: nil)
        }
        
        // if this view controller is loaded from a storyboard, imageURL will be nil
        
        required init?(coder aDecoder: NSCoder) {
            super.init(coder: aDecoder)
        }
    
    @IBOutlet weak var usernameOutlet: UITextField!
    @IBOutlet weak var passwordOutlet: UITextField!
    @IBOutlet weak var switchActionOutlet: UIButton!
    @IBOutlet weak var loginSignUpoutlet: UIButton!
    
    @IBAction func signUpAndLogin(_ sender: UIButton) {
        if usernameOutlet.text == "" || passwordOutlet.text == ""{
            createAlert(for: self, with: "Failed", having: "Please enter email/password!")
        }else{
            if isLogin{
                loginUser()
            }else{
                signUpUser()
            }
        }
    }
    
    @IBAction func switchLoginSignUp(_ sender: UIButton) {
        if isLogin{
            sender.setTitle("Log In", for: [])
            self.loginSignUpoutlet.setTitle("Sign Up", for: [])
            isLogin = false
        }else{
            sender.setTitle("Sign Up", for: [])
            self.loginSignUpoutlet.setTitle("Log In", for: [])
            isLogin = true
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        
    }
    override func viewDidAppear(_ animated: Bool) {
        if let user = Auth.auth().currentUser{
            self.performSegue(withIdentifier: "showUserTable", sender: self)
        }
    }

    func loginUser(){
        let indicator = createActivityIndicator(for: self)
        self.view.isUserInteractionEnabled = false
        indicator.startAnimating()
        Auth.auth().signIn(withEmail: self.usernameOutlet.text!, password: self.passwordOutlet.text!) { [weak self] authResult, error in
            guard let strongSelf = self else { return }
            strongSelf.view.isUserInteractionEnabled = true
            indicator.stopAnimating()
            if let error = error{
                createAlert(for: strongSelf, with: "Error", having: error.localizedDescription)
            }else if let _ = authResult{
                
                strongSelf.performSegue(withIdentifier: "showUserTable", sender: strongSelf)
            }
        }
        
        
    }
    
    func signUpUser(){
        let indicator = createActivityIndicator(for: self)
        self.view.isUserInteractionEnabled = false
        indicator.startAnimating()
        Auth.auth().createUser(withEmail: self.usernameOutlet.text!, password: self.passwordOutlet.text!) { authResult, error in
            self.view.isUserInteractionEnabled = true
            indicator.stopAnimating()
            if let error = error{
                createAlert(for: self, with: "Error", having: error.localizedDescription)
            }else if let authResult = authResult{
                self.saveUser(user: authResult.user)
                self.performSegue(withIdentifier: "showUserTable", sender: self)
            }
        }
    }
    
    func saveUser(user: User){
        self.ref.child("users").child(user.uid).setValue(["email":self.usernameOutlet.text!, "followers":[]])
    }
}

