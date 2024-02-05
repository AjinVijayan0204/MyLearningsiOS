//
//  PostViewController.swift
//  Instagram
//
//  Created by Ajin on 05/02/24.
//

import UIKit
import PhotosUI

class PostViewController: UIViewController {

    @IBOutlet weak var imageOutlet: UIImageView!
    @IBOutlet weak var commentTextField: UITextField!
    
    @IBAction func postButton(_ sender: UIButton) {
        
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
                    if let error = error{
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
