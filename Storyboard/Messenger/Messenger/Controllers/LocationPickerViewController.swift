//
//  LocationPickerViewController.swift
//  Messenger
//
//  Created by Ajin on 16/03/24.
//

import UIKit
import CoreLocation
import MapKit

class LocationPickerViewController: UIViewController {
    
    public var completion: ((CLLocationCoordinate2D)-> Void)?
    private var coordinates: CLLocationCoordinate2D?
    public var isPickable: Bool = true
    private let map: MKMapView = {
        let map = MKMapView()
        return map
    }()

    init(coordinates: CLLocationCoordinate2D?){
        self.coordinates = coordinates
        self.isPickable = coordinates == nil
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        setupView()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        map.frame = view.bounds
    }
    func setupView(){
        view.backgroundColor = .systemBackground
        if isPickable{
            title = "Pick the location"
            navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Send",
                                                                style: .done,
                                                                target: self,
                                                                action: #selector(sendButtonTapped))
            let gesture = UITapGestureRecognizer(target: self,
                                              action: #selector(didTapMap(gesture: )))
            gesture.numberOfTouchesRequired = 1
            gesture.numberOfTapsRequired = 1
            map.addGestureRecognizer(gesture)
        }else{
            //showing the location
            guard let coordinates = self.coordinates else{
                return
            }
            let pin = MKPointAnnotation()
            pin.coordinate = coordinates
            map.addAnnotation(pin)
        }

        view.addSubview(map)
        map.isUserInteractionEnabled = true
        
    }

    @objc func sendButtonTapped(){
        guard let coordinates = coordinates else{
            return
        }
        navigationController?.popViewController(animated: true)
        completion?(coordinates)
    }
    
    @objc func didTapMap(gesture: UITapGestureRecognizer){
        let locationInView = gesture.location(in: map)
        let coordinates = map.convert(locationInView, toCoordinateFrom: map)
        
        map.removeAnnotations(map.annotations)
        //drop a pin on that location
        let pin = MKPointAnnotation()
        pin.coordinate = coordinates
        map.addAnnotation(pin)
        self.coordinates = coordinates
    }
}
