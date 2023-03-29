//
//  DDServer.swift
//  driver-dash-2023
//
//  Created by Jason Klein on 3/27/23.
//

import Foundation
import SwiftSocket

class DDServer: NSObject {
    let address: String
    let port: Int32
    
    let model: DriverDashModel
    let packet: Coder.Packet
    
    init(address: String, port: Int, for packet: Coder.Packet, with model: DriverDashModel) {
        self.address = address
        self.port = Int32(port)
        self.packet = packet
        self.model = model
        
        super.init()
        
        let serverThread = ServerThread(controller: self)
        serverThread.start()
    }
    
    private class ServerThread: Thread {
        let controller: DDServer!
        let serializer: Serializer!
        
        // string form
        let packet: String
        
        init(controller: DDServer) {
            self.serializer = Serializer()
            // reference needed so we can update state
            self.controller = controller
            self.packet = self.controller.packet.rawValue
            
            super.init()
        }
        
        override func main() {
            let server = TCPServer(
                address: self.controller.address,
                port: self.controller.port)
            
            defer {
                print("Closing down the \(self.packet) server.")
                server.close()
            }
            
            switch server.listen() {
              case .success:
                let side = self.controller.packet.rawValue.capitalized
                print("\(side) server listening at \(self.controller.address):\(self.controller.port)!")
                
                while true {
                    // accept() stalls until something connects
                    if let client = server.accept() {
                        // we connected!
                        print("\(self.packet.capitalized) has a new connection!")
                        updateStatus(connected: true)
                        
                        handle(client)
                        
                        // if we're here then we disconnected
                        print("A client disconnected from the \(self.packet) server")
                        updateStatus(connected: false)
                    } else {
                        print("accept error")
                    }
                }
                
              case .failure(let error):
                print(error.localizedDescription)
                print("You probably have the wrong phone IP address")
            }
        }
        
        private func updateStatus(connected: Bool) {
            let model = self.controller.model
            
            DispatchQueue.main.async {
                switch (self.controller.packet) {
                    case .front:
                        model.frontSocketConnected = connected
                    case .back:
                        model.backSocketConnected = connected
                    case .lord:
                        model.lordSocketConnected = connected
                }
            }
        }
        
        private func handle(_ client: TCPClient) {
            print("New client from: \(client.address):\(client.port)")
            
            // receive length of packet in 4 bytes
            // read() waits until we have all 4 bytes
            while let length_b = client.read(4) {
                let data = Data(bytes: length_b, count: 4)
                let length = UInt32(littleEndian: data.withUnsafeBytes {
                    // see https://stackoverflow.com/a/32770113
                    pointer in return pointer.load(as: UInt32.self)
                })
                
                // wait until we have the next length packets
                if let content_b = client.read(Int(length)) {
                    switch self.controller.packet {
                        case .front:
                            let json = Coder().decode(
                                from: Data(content_b),
                                ofType: Coder.FrontPacket.self)
                            // preview parsed data
                            print(Coder().encode(from: json))
                            
                            // defer file-writing to be async
                            DispatchQueue.global().async {
                                self.serializer.serialize(data: json)
                            }
                        
                        case .back:
                            let json = Coder().decode(
                                from: Data(content_b),
                                ofType: Coder.BackPacket.self)
                            // preview parsed data
                            print(Coder().encode(from: json))
                            
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
                            
                            // defer file-writing to be async
                            DispatchQueue.global().async {
                                self.serializer.serialize(data: json)
                            }
                        
                        case .lord:
                            print(String(bytes: Data(content_b), encoding: .utf8)!)
//                        let json = Coder().decode(
//                            from: content_b,
//                            ofType: Coder.LordPacket.self)
                    }
                }
            }
        }
    }
}
