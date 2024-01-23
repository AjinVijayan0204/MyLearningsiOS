//
//  ViewController.swift
//  Memorable Places
//
//  Created by Ajin on 21/01/24.
//

import UIKit
import MapKit
import CoreLocation

class ViewController: UIViewController {

    @IBOutlet weak var mapView: MKMapView!
    
    var locationManager = CLLocationManager()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        let uilpr = UILongPressGestureRecognizer(target: self, action: #selector(ViewController.longPressRecongition(gesture:)))
        uilpr.minimumPressDuration = 2
        self.mapView.addGestureRecognizer(uilpr)
        if activePlace != -1{
            if places.count > activePlace{
                if let name = places[activePlace]["name"]{
                    if let lat = places[activePlace]["lat"], let latitude = Double(lat){
                        if let lon = places[activePlace]["lon"], let longitude = Double(lon){
                            let span = MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05)
                            let coordinate = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
                            let region = MKCoordinateRegion(center: coordinate, span: span)
                            self.mapView.setRegion(region, animated: true)
                            self.mapView.addAnnotation(createAnnotation(title: name, for: coordinate))
                        }
                    }
                }
            }
        }else{
            locationManager.delegate = self
            locationManager.desiredAccuracy = kCLLocationAccuracyBest
            locationManager.requestWhenInUseAuthorization()
            locationManager.startUpdatingLocation()
            let span = MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05)
            let location = locationManager.location
            let region = MKCoordinateRegion(center: location!.coordinate, span: span)
            self.mapView.setRegion(region, animated: true)
            self.mapView.addAnnotation(createAnnotation(title: "new", for: location!.coordinate))
        }
    }

    override func viewWillDisappear(_ animated: Bool) {
        UserDefaults.standard.set(places, forKey: "places")
    }
}

extension ViewController: MKMapViewDelegate, CLLocationManagerDelegate{
    
}

extension ViewController{
    @objc func longPressRecongition(gesture: UIGestureRecognizer){
        if gesture.state == UIGestureRecognizer.State.began{
            let touchPoint = gesture.location(in: self.mapView)
            let newCoordinate = self.mapView.convert(touchPoint, toCoordinateFrom: self.mapView)
            let location = CLLocation(latitude: newCoordinate.latitude, longitude: newCoordinate.longitude)
            var title = ""
            CLGeocoder().reverseGeocodeLocation(location) { placemark, error in
                if let error = error{
                    print(error)
                }else{
                    if let placemark = placemark?[0]{
                        let place = placemark.description.split(separator: ",")
                        title += String(place.first!)
                        if place[0].trimmingCharacters(in: .whitespacesAndNewlines) != place[1].trimmingCharacters(in: .whitespacesAndNewlines){
                            title += String(place[1])
                        }else{
                            title += String(place[2])
                        }
                        self.mapView.addAnnotation(self.createAnnotation(title: title, for: placemark.location!.coordinate))
                        places.append(["name": title, "lat": String(placemark.location!.coordinate.latitude), "lon": String(placemark.location!.coordinate.longitude)])
                    }
                }
            }
        }
    }
}

extension ViewController{
    func createAnnotation(title: String, for coordinate: CLLocationCoordinate2D) -> MKPointAnnotation{
        let annotation = MKPointAnnotation()
        annotation.coordinate = coordinate
        annotation.title = title
        return annotation
    }
}
