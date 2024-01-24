# MyLearningsiOS

SwiftUI
- sheet presentation
    screen size adjusting -> .presentationDetents([.height(300), .medium])
- UIRepresentable to create UIkit views in SwiftUI
      - for creating gesture recognition create a coordinator class inside the UIRepresentable.(refer twitter animation swiftui)

  Animation in UIKit
      - UIView.animate(withDuration: <#T##TimeInterval#>, animations: <#T##() -> Void#>)

  Select views based on tags
      - first assign views/buttons with tags in storyboard
      - next create those things in code
          for example: - set of buttons with tags
                          if let button = view.viewWithTag(i) as? UIButton{
                                button.configuration?.image = nil
                            }

Gestures
        eg: let uilpr = UILongPressGestureRecognizer(target: self, action: #selector(ViewController.longPressRecongition(gesture:)))
            uilpr.minimumPressDuration = 2
            self.mapView.addGestureRecognizer(uilpr)
            
Maps
    let span = MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05)
    let coordinate = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
    let region = MKCoordinateRegion(center: coordinate, span: span)
    self.mapView.setRegion(region, animated: true)
    self.mapView.addAnnotation(createAnnotation(title: name, for: coordinate))   

Current location
    Add privacy location in info plist
    eg: var locationManager = CLLocationManager()
          locationManager.delegate = self
            locationManager.desiredAccuracy = kCLLocationAccuracyBest
            locationManager.requestWhenInUseAuthorization()
            locationManager.startUpdatingLocation()
            let span = MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05)
            let location = locationManager.location
            let region = MKCoordinateRegion(center: location!.coordinate, span: span)
            self.mapView.setRegion(region, animated: true)
            self.mapView.addAnnotation(createAnnotation(title: "new", for: location!.coordinate))

Get location from mapview 
eg: by using CLGeocoder and its reverseGeocodeLocation
    if gesture.state == UIGestureRecognizer.State.began{
            let touchPoint = gesture.location(in: self.mapView)
            let newCoordinate = self.mapView.convert(touchPoint, toCoordinateFrom: self.mapView)
            let location = CLLocation(latitude: newCoordinate.latitude, longitude: newCoordinate.longitude)
            var title = ""
            CLGeocoder().reverseGeocodeLocation(location) { placemark, error in
            }
        }
    
