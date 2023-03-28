//
//  MapModel.swift
//  driver-dash-2023
//
//  Created by Jason Klein on 3/27/23.
//

import Foundation
import MapKit

//handles the authorization to allow use of locations
class MapModel: NSObject, ObservableObject, CLLocationManagerDelegate {  
    private let manager = CLLocationManager()
    
    override init() {
        super.init()
        
        manager.requestWhenInUseAuthorization()
        manager.delegate = self
        
        manager.startUpdatingLocation()
    }
}

