//
//  DriverDashModel.swift
//  driver-dash-2023
//
//  Created by Jason Klein on 3/25/23.
//

import SwiftUI
import CoreLocation

// have two UserDefaults keys, one for front-daq and one for back-daq
// each one has the timestamp: { data } format I outlined for Drew
// note that the location comes with a timestamp!

// see this for clearing it https://developer.apple.com/documentation/foundation/userdefaults/1415919-dictionaryrepresentation

class DriverDashModel: NSObject, ObservableObject {
    @Published var speed = 0.0
    @Published var power = 0.0
    
    var location: CLLocation?

    override init() {
        super.init()
    }
}
