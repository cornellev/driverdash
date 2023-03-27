//
//  Coder.swift
//  driver-dash-2023
//
//  Created by Jason Klein on 3/25/23.
//

import SwiftUI

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
    
    func decode<T: Codable>(from payload: Data, type: T.Type) -> T {
        let decoder = JSONDecoder()
        return try! decoder.decode(T.self, from: payload)
    }
    
    func decode<T: Codable>(from payload: String, type: T.Type) -> T {
        let data = payload.data(using: .utf8)!
        return decode(from: data, type: type)
    }
    
    // assumes all payloads are valid. Will crash if not!
    func decodeFrontDAQ(from payload: String) -> FrontPacket {
        return decodeFrontDAQ(from: payload.data(using: .utf8)!)
    }
    
    func decodeFrontDAQ(from payload: Data) -> FrontPacket {
        do {
            return try JSONDecoder().decode(FrontPacket.self, from: payload)
        } catch let error {
            print("decodeFrontDAQ error: \(error.localizedDescription)")
            return FrontPacket()
        }
    }
    
    func encodeFrontDAQ(from packet: FrontPacket) -> String {
        do {
            let encoded = try JSONEncoder().encode(packet)
            return String(data: encoded, encoding: .utf8)!
        } catch let error {
            print("decodeFrontDAQ error: \(error.localizedDescription)")
            return ""
        }
    }
    
    func decodeBackDAQ(from payload: String) -> BackPacket {
        return decodeBackDAQ(from: payload.data(using: .utf8)!)
    }
    
    func decodeBackDAQ(from payload: Data) -> BackPacket {
        do {
            return try JSONDecoder().decode(BackPacket.self, from: payload)
        } catch let error {
            print("decodeBackDAQ error: \(error.localizedDescription)")
            return BackPacket()
        }
    }
    
    func encodeBackDAQ(from packet: BackPacket) -> String {
        do {
            let encoded = try JSONEncoder().encode(packet)
            return String(data: encoded, encoding: .utf8)!
        } catch let error {
            print("decodeBackDAQ error: \(error.localizedDescription)")
            return ""
        }
    }
}
