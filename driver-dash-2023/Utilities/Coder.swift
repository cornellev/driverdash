//
//  Coder.swift
//  driver-dash-2023
//
//  Created by Jason Klein on 3/25/23.
//

import Foundation

class Coder {
    enum Packet: String {
        case front = "front"
        case back = "back"
        case lord = "lord"
        case phone = "phone"
    }
    
    struct FrontPacket: Codable {
        var throttle: Double?
        var angle: Double?
        var tof: Double?
    }
    
    struct BackPacket: Codable {
        struct Acceleration: Codable {
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
        
        var acceleration: Acceleration?
        
        var rtk: RTK?
    }
    
    struct LordPacket: Codable {
        struct Acceleration: Codable {
            var x: Double
            var y: Double
            var z: Double
        }
        
        struct Gyro: Codable {
            var pitch: Double
            var roll: Double
            var yaw: Double
        }
        
        var latitude: Double?
        var longitude: Double?
        
        // LORD's groundSpeed
        var speed: Double?
        var heading: Double?
        
        var acceleration: Acceleration?
        
        var gyro: Gyro?
    }
    
    struct PhonePacket: Codable {
        var latitude: Double
        var longitude: Double
        var heading: Double
        var speed: Double
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
