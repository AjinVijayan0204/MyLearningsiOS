//
//  ViewController.swift
//  LocationAware
//
//  Created by Ajin on 21/01/24.
//

import UIKit
import CoreLocation
import MapKit

class ViewController: UIViewController {

    @IBOutlet weak var latitudeLabel: UILabel!
    @IBOutlet weak var longitudeLabel: UILabel!
    @IBOutlet weak var speedLabel: UILabel!
    @IBOutlet weak var nearestAdressLabel: UILabel!
    @IBOutlet weak var mapView: MKMapView!
    
    var locManager = CLLocationManager()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        locManager.delegate = self
        locManager.desiredAccuracy = kCLLocationAccuracyBest
        locManager.requestWhenInUseAuthorization()
        locManager.startUpdatingLocation()
        
        //gesture
        let longPressInteraction = UILongPressGestureRecognizer(target: self, action: #selector(ViewController.longPress(gestureRecogniser:)))
        longPressInteraction.minimumPressDuration = 2
        mapView.addGestureRecognizer(longPressInteraction)
    }

}

extension ViewController: CLLocationManagerDelegate{
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        let location = locations[0]
        self.latitudeLabel.text = String(location.coordinate.latitude)
        self.longitudeLabel.text = String(location.coordinate.longitude)
        self.speedLabel.text = String(location.speed)
        CLGeocoder().reverseGeocodeLocation(location) { placemark, error in
            if let error = error{
                print(error)
            }else{
                if let placemark = placemark?[0]{
                    var address = ""
                    if let subThoroughfare = placemark.subThoroughfare{
                        address += subThoroughfare + " "
                    }
                    if let thoroughfare = placemark.thoroughfare{
                        address += thoroughfare + " "
                    }
                    if let subLocality = placemark.subLocality{
                        address += subLocality + " "
                    }
                    if let postalCode = placemark.postalCode{
                        address += postalCode + " "
                    }
                    if let country = placemark.country{
                        address += country + " "
                    }
                    self.nearestAdressLabel.text = address
                    
                    let (lanDelta, longDelta): (CLLocationDegrees, CLLocationDegrees) = (0.05, 0.05)
                    let span = MKCoordinateSpan(latitudeDelta: lanDelta, longitudeDelta: longDelta)
                    let coordinates = CLLocationCoordinate2D(latitude: location.coordinate.latitude, longitude: location.coordinate.longitude)
                    let annotation = MKPointAnnotation()
                    annotation.title = "Me"
                    annotation.coordinate = coordinates
                    let region = MKCoordinateRegion(center: coordinates, span: span)
                    self.mapView.setRegion(region, animated: true)
                    self.mapView.addAnnotation(annotation)
                }
            }
        }
    }
}


//for gesture recognition

extension ViewController{
    
    @objc func longPress(gestureRecogniser: UIGestureRecognizer){
        let touchPoint = gestureRecogniser.location(in: self.mapView)
        let coordinate = mapView.convert(touchPoint, toCoordinateFrom: self.mapView)
        let annotation = MKPointAnnotation()
        annotation.title = "Wish loc"
        annotation.coordinate = coordinate
        mapView.addAnnotation(annotation)
    }
}


