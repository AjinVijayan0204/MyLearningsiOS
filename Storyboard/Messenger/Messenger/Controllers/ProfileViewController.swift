//
//  ProfileViewController.swift
//  Messenger
//
//  Created by Ajin on 20/02/24.
//

import UIKit
import FirebaseAuth
import FacebookLogin
import GoogleSignIn
import SDWebImage


class ProfileViewController: UIViewController {

    @IBOutlet var tableView: UITableView!
    
    var data = [ProfileViewModel]()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        tableView.register(ProfileTableViewCell.self, forCellReuseIdentifier: "ProfileTableViewCell")
        let name = UserDefaults.standard.value(forKey: "name") as? String ?? "No Name"
        data.append(ProfileViewModel(viewModelType: .info, title: "Name: \(name)", handler: nil))
        let email = UserDefaults.standard.value(forKey: "email") as? String ?? "No Email"
        data.append(ProfileViewModel(viewModelType: .info, title: "Name: \(email)", handler: nil))
        data.append(ProfileViewModel(viewModelType: .logout, title: "Log Out", handler: logOut))
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
        tableView.delegate = self
        tableView.dataSource = self
        tableView.tableHeaderView = createTableHeader()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        tableView.reloadData()
    }
    
    private func logOut(){
        let alert = UIAlertController(title: "Log out", message: "Are you sure to log out!", preferredStyle: .alert)
        let logout = UIAlertAction(title: "Log out", style: .destructive) { [weak self] _ in
            guard let strongSelf = self else { return }
           
            ///clear user defaults
            UserDefaults.standard.set(nil, forKey: "email")
            UserDefaults.standard.set(nil, forKey: "name")
            UserDefaults.standard.set(nil, forKey: "profile_picture_url")
            print("Clearing cache...logging out")
            ///Facebook logout
            FBSDKLoginKit.LoginManager().logOut()
            
            ///Google logout
            GIDSignIn.sharedInstance.signOut()
           
            do{
                try Auth.auth().signOut()
                let vc = LoginViewController()
                let nav = UINavigationController(rootViewController: vc)
                nav.modalPresentationStyle = .fullScreen
                strongSelf.present(nav, animated: true)
            }catch{
                print("Failed to Logout")
            }
        }
        let cancel = UIAlertAction(title: "Cancel", style: .cancel)
        alert.addAction(cancel)
        alert.addAction(logout)
        self.present(alert, animated: true)
    }
    
    func createTableHeader() -> UIView?{
        guard let email = UserDefaults.standard.value(forKey: "email") as? String else{
            return nil
        }
        let safeEmail = DatabaseManager.getSafeEmail(email: email)
        let filename = safeEmail + "_profile_picture.png"
        let path = "images/"+filename
        
        let headerView = UIView(frame: CGRect(x: 0,
                                        y: 0,
                                        width: self.view.width,
                                        height: 300))
        headerView.backgroundColor = .link
        let imageView = UIImageView(frame: CGRect(x: (headerView.width-150)/2,
                                                  y: 75,
                                                  width: 150,
                                                  height: 150))
        imageView.contentMode = .scaleAspectFit
        imageView.layer.borderColor = UIColor.white.cgColor
        imageView.layer.borderWidth = 3
        imageView.layer.masksToBounds = true
        imageView.layer.cornerRadius = imageView.width/2
        imageView.backgroundColor = .white
        headerView.addSubview(imageView)
        
        StorageManager.shared.downloadUrl(for: path) { [weak self]result in
            guard let strongSelf = self else{ return }
            switch result{
            case .success(let url):
                strongSelf.downloadImage(imageView: imageView, url: url)
            case .failure(let error):
                print("errror is \(error)")
            }
        }
        return headerView
    }
    
    private func downloadImage(imageView: UIImageView, url: URL){
        imageView.sd_setImage(with: url)
    }
}

extension ProfileViewController: UITableViewDelegate, UITableViewDataSource{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return data.count
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let viewModel = data[indexPath.row]
        let cell = tableView.dequeueReusableCell(withIdentifier: ProfileTableViewCell.identifier, for: indexPath) as! ProfileTableViewCell
        cell.setUp(with: viewModel)
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        data[indexPath.row].handler?()
    }
    
}

class ProfileTableViewCell: UITableViewCell{
    
    static let identifier = "ProfileTableViewCell"
    
    public func setUp(with viewModel: ProfileViewModel){
        self.textLabel?.text = viewModel.title
        switch viewModel.viewModelType{
        case .info:
            selectionStyle = .none
        case .logout:
            textLabel?.textColor = .red
            textLabel?.textAlignment = .center
        }
    }
}
