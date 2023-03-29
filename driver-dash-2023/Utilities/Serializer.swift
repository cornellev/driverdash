//
//  Serializer.swift
//  driver-dash-2023
//
//  Created by Jason Klein on 3/27/23.
//

import Foundation

class Serializer: NSObject {
    let fileManager = FileManager.default
    
    var filePath: URL!
    var fileHandle: FileHandle!
    let packetType: Coder.Packet
    
    init(for packetType: Coder.Packet) {
        self.packetType = packetType
        super.init()
        
        let filename = {
            switch(packetType) {
                case .front: return "front-daq.json"
                case .back: return "back-daq.json"
                case .lord: return "lord.json"
                case .phone: return "phone.json"
        }}()
        
        self.filePath = pathInDocuments(for: filename)
        
        // create empty files if they don't exist
        if !fileManager.fileExists(atPath: filePath.path) {
            let brace = "{".data(using: .utf8)
            fileManager.createFile(atPath: filePath.path, contents: brace)
        }
        
        self.fileHandle = FileHandle(forWritingAtPath: filePath.path)!
        
        defer {
            do {
                try fileHandle.close()
            } catch let error {
                print("Unable to close file for \(packetType.rawValue). Error was \(error.localizedDescription)")
            }
        }
    }
    
    func serialize(data: Codable) {
        let stringified = Coder().encode(from: data)
        let timestamp = getTimestamp(from: localDate())

        do {
            try "\"\(timestamp)\": \(stringified),\n".appendToURL(fileURL: filePath)
        } catch let error {
            print("Error serializing \(packetType.rawValue) packet: \(error.localizedDescription)")
        }
    }
    
    private func pathInDocuments(for path: String) -> URL {
        let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        return paths.first!.appendingPathComponent(path, conformingTo: .text)
    }
    
    private func getTimestamp(from date: Date) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.timeZone = TimeZone(abbreviation: "GMT")!
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss.SSSSS"
        return dateFormatter.string(from: date)
    }
    
    private func localDate() -> Date {
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
