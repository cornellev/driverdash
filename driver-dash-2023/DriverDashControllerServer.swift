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
        let controller: DriverDashController!
        let serializer: Serializer!
        
        init(controller: DriverDashController) {
            // reference needed so we can update state
            self.controller = controller
            self.serializer = Serializer()
            super.init()
        }
        
        override func main() {
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
            while var bytes = client.read(4) {
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
                        
                        // since changing the model updates the UI, we have to make updates on the main thread.
                        // this will update as soon as the main thread is able.
                        DispatchQueue.main.async {
                            if let power = json.voltage {
                                self.controller.model.power = power
                            }
                            
                            if let rpm = json.rpm {
                                // todo: use circumference/diameter of wheel
                                self.controller.model.speed = Double(rpm) / 5
                            }
                        }
                        
                        // also defer file-writing to be async, but use a serial
                        // queue so we don't try writing at the same time
                        DispatchQueue.main.sync {
                            self.serializer.serialize(data: json)
                        }
                        
                        print(json)
                        print(try! String(data: encoder.encode(json), encoding: .utf8)!)
                        
                    } catch let error {
                        print("Error reading JSON: \(error.localizedDescription)")
                    }
                }
            }
        }
    }
       
    func initServer() {
        let serverThread = ServerThread(controller: self)
        serverThread.start()
    }
    
}
