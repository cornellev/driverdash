//
//  DDLocation.swift
//  driver-dash-2023
//
//  Created by Jason Klein on 3/27/23.
//

import Foundation
import CoreLocation

class DDLocation: NSObject, CLLocationManagerDelegate {
    private let manager = CLLocationManager()
    private let serializer = Serializer(for: .phone)
    private let model: DDModel
    
    init(with model: DDModel) {
        self.model = model
        
        super.init()
        
        manager.desiredAccuracy = kCLLocationAccuracyBest
        manager.requestWhenInUseAuthorization()
        manager.delegate = self
        
        manager.startUpdatingLocation()
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        // update connection status
        if !model.phoneConnected {
            model.phoneConnected = true
        }
        
        // keep the current location up to date as much as possible
        if let location = locations.last {
            serializer.serialize(data: Coder.PhonePacket(
                latitude: location.coordinate.latitude,
                longitude: location.coordinate.longitude,
                // see https://stackoverflow.com/a/39173538
                heading: max(0, location.course),
                speed: max(0, location.speed)))
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        // todo: is there a better way to handle errors than this?
        print("Whoopsies. Had trouble getting the location.")
        model.phoneConnected = false
    }
}
