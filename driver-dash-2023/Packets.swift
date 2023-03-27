//
//  Packets.swift
//  driver-dash-2023
//
//  Created by Jason Klein on 3/25/23.
//

import SwiftUI

// note: timestamps need to be handled in the Swift code

struct FrontPacket: Codable {
    var throttle: Double?
    var angle: Double?
    var tof: Double?
}

struct BackPacket: Codable {
    // gps data
    struct Lord: Codable {
        var x: Double
        var y: Double
        var z: Double
    }
    
    // acceleration
    struct Accelerometer: Codable {
        var pitch: Double
        var roll: Double
        var yaw: Double
        var x: Double
        var y: Double
        var z: Double
    }
    
    struct RTK: Codable {
        var latitude: Double
        var longitude: Double
    }
    
    var rpm: Int?
    
    // average value
    var voltage: Double?
    
    // 1 == engaged
    var safety: Int?
    
    var lord: Lord?
    
    var accelerometer: Accelerometer?
    
    var rtk: RTK?
}

// assumes all payloads are valid. Will crash if not!
func decodeFrontDAQ(from payload: String) -> FrontPacket {
    try! JSONDecoder().decode(FrontPacket.self, from: payload.data(using: .utf8)!)
}

func decodeBackDAQ(from payload: String) -> BackPacket {
    try! JSONDecoder().decode(BackPacket.self, from: payload.data(using: .utf8)!)
}
