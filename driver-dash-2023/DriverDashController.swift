//
//  DriverDashController.swift
//  driver-dash-2023
//
//  Created by Jason Klein on 3/27/23.
//

import SwiftUI
import CoreLocation

class DriverDashController: NSObject {
    var manager: CLLocationManager?
    
    private var frontFile: FileHandle!
    private var backFile: FileHandle!
    
    let model: DriverDashModel!
    
    init(model: DriverDashModel) {
        self.model = model
        
        super.init()
        self.initServer()
        self.initLocation()
    }
}
