//
//  PostViewController.swift
//  Instagram
//
//  Created by Ajin on 05/02/24.
//

import UIKit
import PhotosUI
import FirebaseDatabase
import FirebaseAuth
import FirebaseStorage

class PostViewController: UIViewController {

    let ref: DatabaseReference = Database.database().reference()
    let storageRef = Storage.storage().reference()
    
    @IBOutlet weak var imageOutlet: UIImageView!
    @IBOutlet weak var commentTextField: UITextField!
    
    @IBAction func postButton(_ sender: UIButton) {
        let indicator = createActivityIndicator(for: self)
        self.view.isUserInteractionEnabled = false
        indicator.startAnimating()
        if let user = Auth.auth().currentUser{
            if let image = imageOutlet.image, commentTextField.text != ""{
                let path = user.uid + Date().description
                self.ref.child("posts").child(user.uid).child(Date().description).setValue(["comment": commentTextField.text!, "image": path])
                guard let imageData = image.pngData() else { return }
                let _ = storageRef.child("posts").child(user.uid).child(path).putData(imageData) { metadata, error in
                    if let error = error{
                        createAlert(for: self, with: "Posting Failed", having: error.localizedDescription)
                    }else if let _ = metadata{
                        createAlert(for: self, with: "Posted", having: "The feed is posted successfully!!")
                    }
                    self.view.isUserInteractionEnabled = true
                    indicator.stopAnimating()
                    //guard let metadata = metadata else { return }
                    //self.storageRef.child("posts").child(path).downloadURL { url, error in
                        
                    //}
                }
            }
        }
    }
    @IBAction func chooseImageBtn(_ sender: UIButton) {
        var configuration = PHPickerConfiguration()
        configuration.selectionLimit = 1
        configuration.filter = .images
        let pickerVC = PHPickerViewController(configuration: configuration)
        pickerVC.delegate = self
        self.present(pickerVC, animated: true)
    }
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
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

extension PostViewController: PHPickerViewControllerDelegate{
    func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
        self.dismiss(animated: true)
        if let itemprovider = results.first?.itemProvider{
            if itemprovider.canLoadObject(ofClass: UIImage.self){
                itemprovider.loadObject(ofClass: UIImage.self) { image, error in
                    if let _ = error{
                        print("Error in loading image")
                    }else if let selectedImage = image as? UIImage{
                        DispatchQueue.main.async {
                            self.imageOutlet.image = selectedImage
                        }
                    }
                }
            }
        }
    }
}
