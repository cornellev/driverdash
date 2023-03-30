//
//  DDModel.swift
//  driver-dash-2023
//
//  Created by Jason Klein on 3/25/23.
//

import SwiftUI
import CoreLocation

class DDModel: NSObject, ObservableObject {
    @Published var speed = 0.0
    @Published var power = 0.0
    
    @Published var daqSocketConnected = false
    @Published var lordSocketConnected = false
    
    var location: CLLocation?
}
