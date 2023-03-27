//
//  DriverDashController.swift
//  driver-dash-2023
//
//  Created by Jason Klein on 3/27/23.
//

import SwiftUI
import CoreLocation

class DriverDashController: NSObject {
    private var locationManager: CLLocationManager!
    
    private var frontFile: FileHandle!
    private var backFile: FileHandle!
    
    private let model: DriverDashModel!
    
    init(model: DriverDashModel) {
        self.model = model
    }
    
    func initLocation() {
        // set up phone GPS tracking
        locationManager = CLLocationManager()
        // not sure what I want the accuracy level to be
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.requestWhenInUseAuthorization()
        locationManager.delegate = self
        
        locationManager.startUpdatingLocation()
    }
}

extension DriverDashController: CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        //. keep the current location up to date as much as possible
        if let location = locations.last {
            self.model.location = location
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        // todo: is there a better way to handle errors than this?
        print("Whoopsies. Had trouble getting the location.")
    }
}
