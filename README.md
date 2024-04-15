# MyLearningsiOS

# SwiftUI

# - sheet presentation
    screen size adjusting -> .presentationDetents([.height(300), .medium])
- UIRepresentable to create UIkit views in SwiftUI
      - for creating gesture recognition create a coordinator class inside the UIRepresentable.(refer twitter animation swiftui)

# UIKit

## PageView Controller
    1. Declaration
    eg: let pageViewController: UIPageViewController

    2. Creation
    eg: pageViewController = UIPageViewController(transitionStyle: .scroll,
                                                  navigationOrientation: .horizontal)
    
    3. Adding to ViewController
    eg: addChild(pageViewController)
        view.addSubview(pageViewController.view)
        pageViewController.didMove(toParent: self)

    4. Add datasource functions
        1. assign data source
        eg: pageViewController.dataSource = self

        2. before ViewController
        eg: func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController?

        3. After ViewController
        eg: func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController?

        4. No of pages
        eg: func presentationCount(for pageViewController: UIPageViewController) -> Int

        5. Current index
        eg: func presentationIndex(for pageViewController: UIPageViewController) -> Int

 # Animation in UIKit
      - UIView.animate(withDuration: <#T##TimeInterval#>, animations: <#T##() -> Void#>)

## CAKeyframeAnimation

    eg: let animation = CAKeyframeAnimation()
        animation.keyPath = "position.x"
        animation.values = [0, 10, -10, 10, 0]
        animation.keyTimes = [0, 0.25, 0.5, 0.75, 1]
        animation.duration = 0.4
        
        animation.isAdditive = true
        signInBtn.layer.add(animation, forKey: "shake")

## sequential animation

    eg: let numberOfFrames: Double = 6
        let frameDuration = Double(1/numberOfFrames)

        UIView.animateKeyframes(withDuration: duration, delay: 0) {
            UIView.addKeyframe(withRelativeStartTime: 0, relativeDuration: frameDuration) {
                self.imageView.transform = CGAffineTransform(rotationAngle: -angle)
            }
            UIView.addKeyframe(withRelativeStartTime: frameDuration, relativeDuration: frameDuration) {
                self.imageView.transform = CGAffineTransform(rotationAngle: +angle)
            }
            UIView.addKeyframe(withRelativeStartTime: frameDuration*2, relativeDuration: frameDuration) {
                self.imageView.transform = CGAffineTransform(rotationAngle: -angle)
            }
            UIView.addKeyframe(withRelativeStartTime: frameDuration*3, relativeDuration: frameDuration) {
                self.imageView.transform = CGAffineTransform(rotationAngle: +angle)
            }
            UIView.addKeyframe(withRelativeStartTime: frameDuration*4, relativeDuration: frameDuration) {
                self.imageView.transform = CGAffineTransform(rotationAngle: -angle)
            }
            UIView.addKeyframe(withRelativeStartTime: frameDuration*5, relativeDuration: frameDuration) {
                self.imageView.transform = CGAffineTransform.identity
            }
        }

  # Select views based on tags
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

# Adding nib file
    1. Create the UIView cocoa touch file and a nib file(View) with the same name.
    2. link the nib file's owner with the cocoa touch class name(in identity inspector).
    3. Inside the cocoa touch class
        a. create an outlet for the view from nib file.
        b. create override init(frame: CGRect) and required init?(coder: NSCoder)
        c. from both init's load the nib from the bundle
            eg:let bundle = Bundle(for: AccountSummaryHeaderView.self)
               bundle.loadNibNamed("AccountSummaryHeaderView", owner: self)
               addSubview(contentView)
        d. add the constraints and properties to the content view.
        e. create intrinsic size for the view
            eg: override var intrinsicContentSize: CGSize{
                    return CGSize(width: UIView.noIntrinsicMetric, height: 144)
                 }
    4. Inside the cocoa touch class where the view need to be used, 
        a. initialise the view
            eg: let header = AccountSummaryHeaderView(frame: .zero)
        b. set the size
            eg: var size = header.systemLayoutSizeFitting(UIView.layoutFittingCompressedSize)
                size.width = self.view.bounds.width
                header.frame.size = size
        c. add the view
            eg: tableView.tableHeaderView = header or addsubview(header)..etc

# Table view cell programatically
    1. create a cocoa touch class for table view cell.
    2. create a reuse identifier inside the class
        eg: static let reuseID = "AccountSummaryCell"
    3. create an initialiser
        eg: override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?)
    4. register the cell inside the tableviewcontroller cocoatouch class
        eg: tableView.register(AccountSummaryCell.self,
                           forCellReuseIdentifier: AccountSummaryCell.reuseID)
    5. make use of the cell inside cellforAt datasource method
        eg: let cell = tableView.dequeueReusableCell(withIdentifier: AccountSummaryCell.reuseID, for: indexPath) as! AccountSummaryCell

# Attributed Text
    Create a diff way of viewing the text like raised and all
    eg: let dollarSignAttributes: [NSAttributedString.Key: Any] = [
            .font: UIFont.preferredFont(forTextStyle: .callout),
            .baselineOffset: 8]
        let rootString = NSMutableAttributedString(string: "$", attributes: dollarSignAttributes)
    assign the root string to the attributedtext property of label.

# Notification broadcast
    1. initialise a notification
    eg: extension Notification.Name{
        static let logout = Notification.Name("Logout")
    }

    2. Create notification
    eg:  NotificationCenter.default.addObserver(self,
                                               selector: #selector(<#T##@objc method#>),
                                               name: .logout,
                                               object: nil)
        using object parameter we can pass data between controllers

    3. triggering notification
        eg: NotificationCenter.default.post(name: .logout, object: nil)

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

## Dispatch group
    1. create a dispatch group
        eg: let group = DispatchGroup()

    2. enter and leave the group before and after the work starts and ends respectivey.
        eg: group.enter()
            fetchProfile(userId: "1") { result in
                switch result{
                case .success(let profile):
                    self.profile = profile
                    self.configureTableViewHeaderView(with: profile)
                case .failure(let error):
                    print(error.localizedDescription)
                }
                group.leave()
            } 
        //enter into other job and exit

    3. Notify once the work is over
        eg: group.notify(queue: .main) {
                self.tableView.reloadData()
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
