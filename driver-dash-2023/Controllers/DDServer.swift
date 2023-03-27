//
//  DDServer.swift
//  driver-dash-2023
//
//  Created by Jason Klein on 3/27/23.
//

import Foundation
import SwiftSocket

class DDServer: NSObject {
    // set address to the IP address of *the phone*
    let ADDRESS = "172.20.10.1"
    let PORT = 8080
    
    let model: DriverDashModel
    
    init(with model: DriverDashModel) {
        self.model = model
        
        super.init()
        
        let serverThread = ServerThread(controller: self)
        serverThread.start()
    }
    
    private class ServerThread: Thread {
        let controller: DDServer!
        let serializer: Serializer!
        
        init(controller: DDServer) {
            self.serializer = Serializer()
            // reference needed so we can update state
            self.controller = controller
            
            super.init()
        }
        
        override func main() {
            let ADDRESS = self.controller.ADDRESS
            let PORT = Int32(self.controller.PORT)
            let server = TCPServer(address: ADDRESS, port: PORT)
            
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
            while var bytes = client.read(4) {
                let data = Data(bytes: bytes, count: 4)
                let length = UInt32(littleEndian: data.withUnsafeBytes {
                    // see https://stackoverflow.com/a/32770113
                    pointer in return pointer.load(as: UInt32.self)
                })
                
                bytes = client.read(Int(length))!
                // all data sent to the server will be valid json
                if let content = String(bytes: bytes, encoding: .utf8) {
                    // todo: how to decide whether it's a BackPacket or FrontPacket?
                    var json = Coder().decode(from: content, ofType: Coder.BackPacket.self)
                    
                    // phone's location is better than nothing
                    if let location = self.controller.model.location {
                        if json.rtk == nil {
                            json.rtk = Coder.BackPacket.RTK(
                                latitude: location.coordinate.latitude,
                                longitude: location.coordinate.longitude)
                        }
                    }
                    
                    // since changing the model updates the UI, we have to make updates on the main thread.
                    // this will update as soon as the main thread is able.
                    DispatchQueue.main.async {
                        if let power = json.voltage {
                            self.controller.model.power = power
                        }
                        
                        if let rpm = json.rpm {
                            let diameter = 0.605 // meters
                            let speed = Double(rpm) * diameter * Double.pi * 60 / 1000 // km/h
                            self.controller.model.speed = speed
                        }
                    }
                    
                    // also defer file-writing to be async
                    DispatchQueue.main.async {
                        self.serializer.serialize(data: json)
                    }
                    
                    // show what the data looks like
                    print(json)
                    print(Coder().encode(from: json))
                }
            }
        }
    }
}
