//
//  Saving.swift
//  driver-dash-2023
//
//  Created by Jason Klein on 3/26/23.
//

import SwiftUI

// https://nemecek.be/blog/57/making-files-from-your-app-available-in-the-ios-files-app

// see https://www.hackingwithswift.com/books/ios-swiftui/writing-data-to-the-documents-directory
// returns a URL that would save a file with the given name into the documents directory
func getURLFor(name: String) -> URL {
    let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
    return paths.first!.appendingPathComponent(name, conformingTo: .text)
}

// stringify data to file
//func saveToFile(name: String, data: BackPacket) {
//    // good god this line is long. But it works ¯\_(ツ)_/¯
//    let url = getDocumentsDirectory().appendingPathComponent(name, conformingTo: .text)
//
//    do {
//        // encode and then get the string from it
//        let encoded = try JSONEncoder().encode(data)
//        let stringified = String(data: encoded, encoding: .utf8)!
//        // write the stringified json to the file at url
//        try stringified.write(to: url, atomically: true, encoding: .utf8)
//
//    } catch let error {
//        print(error.localizedDescription)
//    }
//}

//func saveToFile(timestamp: String, data: BackPacket) {
//    
//}
//
//func saveToFile(name: String, data: FrontPacket) {
//    
//}
