//
//  Coder.swift
//  driver-dash-2023
//
//  Created by Jason Klein on 3/25/23.
//

import Foundation

class Coder {
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
    
    struct LordPacket: Codable {
        var gpsCorrelTimestampTow: Double?
        var gpsCorrelTimestampWeekNum: Double?
        var gpsCorrelTimestampFlags: Double?
        var scaledAccelX: Double?
        var scaledAccelY: Double?
        var scaledAccelZ: Double?
        var roll: Double?
        var pitch: Double?
        var yaw: Double?
    }
    
    // assumes all payloads are valid. Will crash if not!
    func decode<T: Codable>(from payload: Data, ofType type: T.Type) -> T {
        let decoder = JSONDecoder()
        return try! decoder.decode(T.self, from: payload)
    }
    
    func decode<T: Codable>(from payload: String, ofType type: T.Type) -> T {
        let data = payload.data(using: .utf8)!
        return decode(from: data, ofType: type)
    }

    func encode<T: Codable>(from packet: T) -> String {
        let encoded = try! JSONEncoder().encode(packet)
        return String(data: encoded, encoding: .utf8)!
    }
}
