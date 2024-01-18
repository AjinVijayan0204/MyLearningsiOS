//
//  ViewController.swift
//  Whats The Weather
//
//  Created by Ajin on 15/01/24.
//

import UIKit

class ViewController: UIViewController {

    @IBOutlet weak var textFieldLocation: UITextField!
    @IBOutlet weak var labelWeatherAtLocation: UILabel!
    
    @IBAction func buttonSearchLocation(_ sender: UIButton) {
        location = textFieldLocation.text ?? "thiruvananthapuram"
        getWeather()
    }
    
    var location: String = "thiruvananthapuram"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        getWeather()
    }

    func getWeather(){
        var weather = ""
        let url = URL(string: "https://www.timeanddate.com/weather/india/\(location)/ext")!
        let request = URLRequest(url: url)
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error{
                print(error)
            }else{
                if let unwrappedData = data{
                    let dataString = String(data: unwrappedData, encoding: String.Encoding(rawValue: String.Encoding.utf8.rawValue))
                    var stringSeperator = "Currently:"
                    let content = dataString?.components(separatedBy: stringSeperator)
                    if let placeContent = content?.last{
                        stringSeperator = "<a href="
                        let newContent = placeContent.components(separatedBy: stringSeperator)
                        if let finalContent = newContent.first{
                            weather = finalContent.replacingOccurrences(of: "</span>", with: "").replacingOccurrences(of: "&nbsp;", with: " ")
                            DispatchQueue.main.async {
                                self.labelWeatherAtLocation.text = weather
                            }
                        }
                    }
                    
                }
            }
        }
        task.resume()
        labelWeatherAtLocation.text = weather
    }
}

