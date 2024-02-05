//
//  UserTableViewController.swift
//  Instagram
//
//  Created by Ajin on 03/02/24.
//

import UIKit
import FirebaseAuth
import FirebaseDatabase

class UserTableViewController: UITableViewController {
    
    var usernames :[String: String] = [:]
    var userFollowing: Set<String> = []
    var ref: DatabaseReference = Database.database().reference()
    var userids: [String]{
        var idSet: Set<String> = Set(usernames.keys)
        idSet.remove(Auth.auth().currentUser!.uid)
        return idSet.sorted()
    }
    
//    convenience init() {
//        self.init()
//    }
        
//    init() {
//        self.ref =
//        super.init(nibName: nil, bundle: nil)
//    }
//    
//    @available(*, unavailable)
//    required init?(coder : NSCoder) {
//        fatalError("init has not implemented")
//    }
    
    @IBAction func logoutAction(_ sender: UIBarButtonItem) {
        try? Auth.auth().signOut()
        self.navigationController?.popToRootViewController(animated: true)
    }
    override func viewDidLoad() {
        super.viewDidLoad()

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem
        
        getUsers()
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        getCurrentUserFollowing()
    }

    // MARK: - Functions
    func getUsers(){
        ref.child("users").getData(completion: { error, snapshot in
            let data = snapshot?.value
            if let data = data as? NSDictionary {
                let _ = data.map { id, value in
                    if let value = value as? NSDictionary{
                        if let email = value["email"] as? String, let id = id as? String{
                            self.usernames[id] = email
                        }
                    }
                    self.tableView.reloadData()
                }
            }
            self.getCurrentUserFollowing()
        })
    }
    
    func getFollowers(for userId: String, completion: @escaping([String]) -> ()){
        var followerList: [String] = []
        let key = "/users/\(userId)/followers"
        ref.child(key).getData { error, snapshot in
            let data = snapshot?.value
            if let data = data, let followers = data as? NSArray{
                followerList = followers.map { follower in
                    return follower as! String
                }
                completion(followerList)
            }else{
                completion([])
            }
        }
        
    }
    
    func getCurrentUserFollowing(){
        if let currentUser = Auth.auth().currentUser{
            for user in userids{
                getFollowers(for: user) { followedBy in
                    if followedBy.contains(currentUser.uid){
                        self.userFollowing.insert(user)
                    }
                    self.tableView.reloadData()
                }
            }
        }
    }
    
    func updateFollowers(for userId: String) {
        if let user = Auth.auth().currentUser{
            let key = "/users/\(userId)/followers"
            getFollowers(for: userId) { followers in
                var newFollowers = Set(followers)
                if newFollowers.contains(user.uid){
                    newFollowers.remove(user.uid)
                    self.userFollowing.remove(userId)
                }else{
                    newFollowers.insert(user.uid)
                    self.userFollowing.insert(userId)
                }
                let updatedArray: [String] = newFollowers.map { data in
                    return data
                }
                let update = [key:updatedArray]
                self.ref.updateChildValues(update) { error, dataRef in
                    self.tableView.reloadData()
                }
            }
            
        }
    }
    
    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return userids.count
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "usercell", for: indexPath)

        // Configure the cell...
        cell.textLabel?.text = usernames[userids[indexPath.row]]
        if userFollowing.contains(userids[indexPath.row]){
            cell.accessoryType = .checkmark
        }else{
            cell.accessoryType = .none
        }
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        updateFollowers(for: userids[indexPath.row])
    }

    /*
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */

    /*
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Delete the row from the data source
            tableView.deleteRows(at: [indexPath], with: .fade)
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    */

    /*
    // Override to support rearranging the table view.
    override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
