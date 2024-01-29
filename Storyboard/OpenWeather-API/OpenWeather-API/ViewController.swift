//
//  ViewController.swift
//  OpenWeather-API
//
//  Created by Ajin on 28/01/24.
//

import UIKit

class ViewController: UIViewController {

    @IBOutlet weak var textFieldOutlet: UITextField!
    @IBAction func getClimateBtn(_ sender: UIButton) {
        if let location = textFieldOutlet.text{
            downloadData(for: location)
        }
    }
    @IBOutlet weak var climateStatusLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        downloadData()
    }

    func downloadData(for place: String = "trivandrum"){
        let url = URL(string: "https://api.openweathermap.org/data/2.5/weather?q=\(place)&appid=ab495d1cffc996e57a31a0c84d1bf0ae")
        if let url = url{
            let request = URLRequest(url: url)
            let task = URLSession.shared.dataTask(with: request) { data, response, error in
                if let error = error{
                    print(error)
                }else{
                    if let data = data{
                        do{
                            //let jsonResult = try JSONSerialization.jsonObject(with: data, options:  .mutableContainers)
                            //print(jsonResult)
                            let finalData = try JSONDecoder().decode(JSONResponse.self, from: data)
                            if let desc = finalData.weather.first?.description{
                                DispatchQueue.main.async {
                                    self.climateStatusLabel.text = desc
                                }
                            }
                        }catch{
                            print("error")
                        }
                        
                    }
                }
            }
            task.resume()
        }
    }
    
    struct JSONResponse: Codable{
        let name: String
        let main: Main
        let weather: [Weather]
    }
    
    struct Main: Codable{
        let temp: Double
        let humidity: Double
    }
    
    struct Weather: Codable{
        let main: String
        let description: String
    }
}

