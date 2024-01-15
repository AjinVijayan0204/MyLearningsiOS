//
//  SecondViewController.swift
//  ToDoList
//
//  Created by Ajin on 15/01/24.
//

import UIKit

class SecondViewController: UIViewController, UITextFieldDelegate {

    @IBOutlet weak var itemTextField: UITextField!
    
    @IBAction func addItem(_ sender: UIButton) {
        let itemObjects = UserDefaults.standard.object(forKey: "items")
        var items: [String]
        if let tempItems = itemObjects as? [String]{
            items = tempItems
            items.append(itemTextField.text!)
        }else{
            items = [itemTextField.text!]
        }
        print(items)
        UserDefaults.standard.set(items, forKey: "items")
        itemTextField.text = ""
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
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
