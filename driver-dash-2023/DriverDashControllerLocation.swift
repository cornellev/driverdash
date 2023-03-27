//
//  DriverDashControllerLocation.swift
//  driver-dash-2023
//
//  Created by Jason Klein on 3/27/23.
//

import Foundation
import CoreLocation

extension DriverDashController: CLLocationManagerDelegate {
    
    func initLocation() {
        if (self.manager == nil){
            // set up phone GPS tracking
            let manager = CLLocationManager()
            manager.desiredAccuracy = kCLLocationAccuracyBest
            manager.requestWhenInUseAuthorization()
            manager.delegate = self
            
            manager.startUpdatingLocation()
            self.manager = manager
        }
    }
    
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
