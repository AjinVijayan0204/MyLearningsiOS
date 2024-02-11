//
//  ViewController.swift
//  LocalNotifications
//
//  Created by Ajin on 10/02/24.
//

import UIKit
import UserNotifications
import CoreLocation

class ViewController: UIViewController {

    @IBAction func requestNotificatonBtn(_ sender: UIButton) {
        requestNotificationAccess()
    }
    
    @IBAction func scheduleNotification(_ sender: UIButton) {
        scheduleNotification()
    }
    
    @IBAction func cancelNotification(_ sender: UIButton) {
        cancelNotification()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        UIApplication.shared.applicationIconBadgeNumber = 0
    }

    //MARK: - Functions
    
    func requestNotificationAccess(){
        let options: UNAuthorizationOptions = [.alert, .badge, .sound]
        UNUserNotificationCenter.current().requestAuthorization(options: options) { success, error in
            if let error = error{
                print("Error - \(error)")
            }else{
                print("Success")
            }
        }
    }
    
    func scheduleNotification(){
        let content = UNMutableNotificationContent()
        content.title = "App notification"
        content.subtitle = "Subtitle"
        content.badge = 1
        content.sound = .default
        
        //time interval trigger
        //let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 5, repeats: false)
        
        //calender trigger
//        var dateComponents = DateComponents()
//        dateComponents.hour = 23
//        dateComponents.minute = 10
//        let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: false)
        
        //location
        let coordinate = CLLocationCoordinate2D(latitude: 40.0,
                                                longitude: 50.0)
        let region = CLCircularRegion(center: coordinate,
                                      radius: 100,
                                      identifier: UUID().uuidString)
        region.notifyOnEntry = true
        region.notifyOnExit = true
        let trigger = UNLocationNotificationTrigger(region: region,
                                                    repeats: false)
        
        let request = UNNotificationRequest(identifier: UUID().uuidString, content: content, trigger: trigger)
        UNUserNotificationCenter.current().add(request)
    }
    
    func cancelNotification(){
        UNUserNotificationCenter.current().removeAllPendingNotificationRequests()
        UNUserNotificationCenter.current().removeAllDeliveredNotifications()
    }
}

