//
//  Serializer.swift
//  driver-dash-2023
//
//  Created by Jason Klein on 3/27/23.
//

import Foundation

class Serializer: NSObject {
    let fileManager = FileManager.default
    
    let frontFilePath = pathInDocuments("front-daq.json")
    let backFilePath = pathInDocuments("back-daq.json")
    
    let frontFile: FileHandle!
    let backFile: FileHandle!
    
    override init() {
        // create files if they don't exist
        if !fileManager.fileExists(atPath: frontFilePath.absoluteString) {
            fileManager.createFile(atPath: frontFilePath.absoluteString, contents: nil)
        }
        
        if !fileManager.fileExists(atPath: backFilePath.absoluteString) {
            fileManager.createFile(atPath: backFilePath.absoluteString, contents: nil)
        }
        
        // open files for writing
        frontFile = try! FileHandle(forWritingTo: frontFilePath)
        backFile = try! FileHandle(forWritingTo: backFilePath)
        
        defer {
            // close files when done with them
            try! frontFile.close()
            try! backFile.close()
        }
        
        super.init()
    }
    
    func serialize(data: FrontPacket) {
        let stringified = encodeFrontDAQ(from: data)
        let timestamp = ISO8601DateFormatter().string(from: localDate())
        
        do {
            let _ = try self.frontFile.seekToEnd()
            try self.frontFile.write(contentsOf: "\(timestamp) \(stringified)".data(using: .utf8)!)
        } catch let error {
            print("Error serializing: \(error.localizedDescription)")
        }
    }

    func serialize(data: BackPacket) {
        let stringified = encodeBackDAQ(from: data)
        let timestamp = ISO8601DateFormatter().string(from: localDate())
        
        do {
            let _ = try self.backFile.seekToEnd()
            try self.backFile.write(contentsOf: "\(timestamp) \(stringified)".data(using: .utf8)!)
        } catch let error {
            print("Error serializing: \(error.localizedDescription)")
        }
    }
    
    static func pathInDocuments(_ path: String) -> URL {
        let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        return paths.first!.appendingPathComponent(path, conformingTo: .text)
    }
    
    func localDate() -> Date {
        // we don't have to deal with daylight savings :)
        // copied from https://stackoverflow.com/a/36282832
        let currentDate = Date()
        let CurrentTimeZone = NSTimeZone(abbreviation: "GMT")
        let SystemTimeZone = NSTimeZone.system as NSTimeZone
        let currentGMTOffset: Int? = CurrentTimeZone?.secondsFromGMT(for: currentDate)
        let SystemGMTOffset: Int = SystemTimeZone.secondsFromGMT(for: currentDate)
        let interval = TimeInterval((SystemGMTOffset - currentGMTOffset!))
        return Date(timeInterval: interval, since: currentDate)
    }
}
