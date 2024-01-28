//
//  ViewController.swift
//  Download Image from web
//
//  Created by Ajin on 28/01/24.
//

import UIKit

class ViewController: UIViewController {

    @IBOutlet weak var imageView: UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        if let image = getImage(){
            self.imageView.image = image
        }else{
            downloadImage()
        }
        
    }

    func downloadImage(){
        let url = URL(string: "https://upload.wikimedia.org/wikipedia/commons/thumb/6/6a/Johann_Sebastian_Bach.jpg/440px-Johann_Sebastian_Bach.jpg")
        if let url = url{
            let request = URLRequest(url: url)
            let task = URLSession.shared.dataTask(with: request) { data, response, error in
                if let _ = error{
                    print("error in downloading image")
                }else{
                    if let data = data{
                        DispatchQueue.main.async {
                            self.imageView.image = UIImage(data: data)
                            self.saveImageToDocuments(image: UIImage(data: data)!)
                        }
                    }else{
                        print("error")
                    }
                }
            }
            task.resume()
        }else{
            print("error in url")
        }
        
    }
    
    func getFilePath() -> URL?{
        let documentsPath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        guard (documentsPath.count > 0) else{
            return nil
        }
        let documentDirectory = documentsPath[0]
        let filename = documentDirectory.appending(path: "/batch.jpg")
        return filename
    }
    
    func saveImageToDocuments(image: UIImage){
        if let fileName = getFilePath(){
            if let imgData = image.jpegData(compressionQuality: 1){
                do{
                    try imgData.write(to: fileName)
                }catch{
                    print("Saving error in documents")
                }
            }
        }
    }

    func getImage() -> UIImage?{
        if let fileName = getFilePath(){
            do{
                let imgData = try Data(contentsOf: fileName)
                return UIImage(data: imgData)
            }catch{
                print("error in loading")
                return nil
            }
        }
        return nil
    }
}

