# MyLearningsiOS

# SwiftUI

# - sheet presentation
    screen size adjusting -> .presentationDetents([.height(300), .medium])
- UIRepresentable to create UIkit views in SwiftUI
      - for creating gesture recognition create a coordinator class inside the UIRepresentable.(refer twitter animation swiftui)

 # Animation in UIKit
      - UIView.animate(withDuration: <#T##TimeInterval#>, animations: <#T##() -> Void#>)

  Select views based on tags
      - first assign views/buttons with tags in storyboard
      - next create those things in code
          for example: - set of buttons with tags
                          if let button = view.viewWithTag(i) as? UIButton{
                                button.configuration?.image = nil
                            }

# Gestures
        eg: let uilpr = UILongPressGestureRecognizer(target: self, action: #selector(ViewController.longPressRecongition(gesture:)))
            uilpr.minimumPressDuration = 2
            self.mapView.addGestureRecognizer(up)

# LOCATION

## Maps
    let span = MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05)
    let coordinate = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
    let region = MKCoordinateRegion(center: coordinate, span: span)
    self.mapView.setRegion(region, animated: true)
    self.mapView.addAnnotation(createAnnotation(title: name, for: coordinate))   

## Current location
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

## Get location from mapview 

    eg: by using CLGeocoder and its reverseGeocodeLocation
        if gesture.state == UIGestureRecognizer.State.began{
            let touchPoint = gesture.location(in: self.mapView)
            let newCoordinate = self.mapView.convert(touchPoint, toCoordinateFrom: self.mapView)
            let location = CLLocation(latitude: newCoordinate.latitude, longitude: newCoordinate.longitude)
            var title = ""
            CLGeocoder().reverseGeocodeLocation(location) { placemark, error in
            }
        }

    
# Saving to document directory
    eg:
        func getFilePath() -> URL?{
            //documents directory path
            let documentsPath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
            guard (documentsPath.count > 0) else{
                return nil
            }
            let documentDirectory = documentsPath[0]
            //filename
            let filename = documentDirectory.appending(path: "/batch.jpg")
            return filename
        }

# Saving and retreiving data from directory
    eg: Saving
        let imgData = image.jpegData(compressionQuality: 1)
        try imgData.write(to: fileName)
    eg: retreiving
        let imgData = try Data(contentsOf: fileName)

# JSON encoding
    eg:
    let finalData = try JSONDecoder().decode(JSONResponse.self, from: data)
    //JSON Model
    struct JSONResponse: Codable{
        let name: String
        let main: Main
        let weather: [Weather]
    }

#  Adding pod
    1. pod init
    2. add the neccessary pods
    3. pod install
    4. if this error comes
    File not found: /Applications/Xcode.app/Contents/Developer/Toolchains/XcodeDefault.xctoolchain/usr/lib/arc/libarclite_iphonesimulator.a
    post_install do |installer|
        installer.generated_projects.each do |project|
            project.targets.each do |target|
                target.build_configurations.each do |config|
                    config.build_settings['IPHONEOS_DEPLOYMENT_TARGET'] = '13.0'
                end
            end
        end
    end

# Asynchronous function
    1. Using completion handlers
    eg:
    func getFollowers(for userId: String, completion: @escaping([String]) -> ()){
        var followerList: [String] = []
        if let user = Auth.auth().currentUser{
            let key = "/users/\(userId)/followers"
            ref.child(key).getData { error, snapshot in
                let data = snapshot?.value
                if let data = data, var followers = data as? NSArray{
                    followerList = followers.map { follower in
                        return follower as! String
                    }
                    //calling on completion
                    completion(followerList)
                }
            }
        }
    }

    //calling
    getFollowers(for: userId) { followers in
               
    }

# Select image (PHPicker)

        var configuration = PHPickerConfiguration()
        configuration.selectionLimit = 1
        configuration.filter = .images
        let pickerVC = PHPickerViewController(configuration: configuration)
        pickerVC.delegate = self
        self.present(pickerVC, animated: true)

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

# Notifications
## Local Notifications  

    1. Request Notification Access
    eg:
    let options: UNAuthorizationOptions = [.alert, .badge, .sound]
        UNUserNotificationCenter.current().requestAuthorization(options: options) { success, error in
            if let error = error{
                print("Error - \(error)")
            }else{
                print("Success")
            }
        }

    2. Create Notification
        1. Create content
            eg: 
            let content = UNMutableNotificationContent()
            content.title = "App notification"
            content.subtitle = "Subtitle"
            content.badge = 1
            content.sound = .default

        2. Create trigger
            a. time interval
                let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 5, repeats: false)
            b. Calender
                let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: false)
            c. location
                create a CLCircularRegion, and pass it.
                let trigger = UNLocationNotificationTrigger(region: region, repeats: false)
        
        3. Create request
            let request = UNNotificationRequest(identifier: UUID().uuidString, content: content, trigger: trigger)
        
        4. Add the request
            UNUserNotificationCenter.current().add(request)
    
    3. Cancel/ Stop notification
        UNUserNotificationCenter.current().removeAllPendingNotificationRequests()
        UNUserNotificationCenter.current().removeAllDeliveredNotifications()
