//
//  DriverDashControllerServer.swift
//  driver-dash-2023
//
//  Created by Jason Klein on 3/27/23.
//

import Foundation
import SwiftSocket

// set address to the IP address of *the phone*
let ADDRESS = "10.48.155.202"
let PORT = 8080

extension DriverDashController {
    
    class ServerThread: Thread {
        override func main() {
            print("hi from a thread!")
        }
    }
       
    func initServer() {
        let thread = ServerThread()
        thread.start()
        
        let server = TCPServer(address: ADDRESS, port: Int32(PORT))
        
        switch server.listen() {
          case .success:
            print("Server listening!")
            while true {
                if let client = server.accept() {
                    handle(client)
                } else {
                    print("accept error")
                }
            }
            
          case .failure(let error):
            print(error.localizedDescription)
            print("You probably have the wrong phone IP address")
        }
    }
    
    func handle(_ client: TCPClient) {
        print("New client from: \(client.address):\(client.port)")
        
        // receive length of packet in 4 bytes
        fetchPacket(from: client)
    }
    
    func fetchPacket(from client: TCPClient) {
        if var bytes = client.read(4) {
            let data = Data(bytes: bytes, count: 4)
            let length = UInt32(littleEndian: data.withUnsafeBytes {
                // see https://stackoverflow.com/a/32770113
                pointer in return pointer.load(as: UInt32.self)
            })
            
            bytes = client.read(Int(length))!
            // all data sent to the server will be valid json
            if let content = String(bytes: bytes, encoding: .utf8) {
                do {
                    let json = try JSONDecoder().decode(BackPacket.self, from: content.data(using: .utf8)!)
                    let encoder = JSONEncoder()
                    encoder.outputFormatting = .prettyPrinted
                    
                    print(json)
                    
                } catch let error {
                    print("Error reading JSON: \(error.localizedDescription)")
                }
            }
        } else {
            print("Tried to fetch a packet but there wasn't one.")
        }
    }
    
}
