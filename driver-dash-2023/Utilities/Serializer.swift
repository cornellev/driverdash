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
        // create empty files if they don't exist
        if !fileManager.fileExists(atPath: frontFilePath.path) {
            fileManager.createFile(atPath: frontFilePath.path, contents: "{".data(using: .utf8))
        }
        
        if !fileManager.fileExists(atPath: backFilePath.path) {
            fileManager.createFile(atPath: backFilePath.path, contents: "{".data(using: .utf8))
        }
        
        // open files for writing
        frontFile = FileHandle(forWritingAtPath: frontFilePath.path)
        backFile = FileHandle(forWritingAtPath: backFilePath.path)
        
        defer {
            // close files when done with them
            try! frontFile.close()
            try! backFile.close()
        }
        
        super.init()
    }
    
    func serialize(data: FrontPacket) {
        let stringified = encodeFrontDAQ(from: data)
        let timestamp = getTimestamp(from: localDate())
        
        do {
            try "\"\(timestamp)\": \(stringified),\n".appendToURL(fileURL: backFilePath)
        } catch let error {
            print("Error serializing: \(error.localizedDescription)")
        }
    }

    func serialize(data: BackPacket) {
        let stringified = encodeBackDAQ(from: data)
        let timestamp = getTimestamp(from: localDate())
        
        do {
            try "\"\(timestamp)\": \(stringified),\n".appendToURL(fileURL: backFilePath)
        } catch let error {
            print("Error serializing: \(error.localizedDescription)")
        }
    }
    
    static func pathInDocuments(_ path: String) -> URL {
        let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        return paths.first!.appendingPathComponent(path, conformingTo: .text)
    }
    
    func getTimestamp(from date: Date) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.timeZone = TimeZone(abbreviation: "GMT")!
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss.SSSSS"
        return dateFormatter.string(from: date)
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


// super helpful snippet from https://stackoverflow.com/a/60199550
extension String {
    func appendToURL(fileURL: URL) throws {
        let data = self.data(using: String.Encoding.utf8)!
        try data.append(fileURL: fileURL)
    }
}

extension Data {
    func append(fileURL: URL) throws {
        if let fileHandle = FileHandle(forWritingAtPath: fileURL.path) {
            defer {
                fileHandle.closeFile()
            }
            fileHandle.seekToEndOfFile()
            fileHandle.write(self)
        }
        else {
            try write(to: fileURL, options: .atomic)
        }
    }
}
