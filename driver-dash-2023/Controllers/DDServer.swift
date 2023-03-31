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
    
    let model: DDModel
    let packetType: Coder.Packet
    
    init(address: String, port: Int, for packetType: Coder.Packet, with model: DDModel) {
        self.address = address
        self.port = Int32(port)
        self.packetType = packetType
        self.model = model
        
        super.init()
        
        let serverThread = ServerThread(controller: self)
        serverThread.start()
    }
    
    private class ServerThread: Thread {
        let controller: DDServer!
        let serializer: Serializer!
        
        // string form
        let packetType: Coder.Packet
        
        init(controller: DDServer) {
            self.packetType = controller.packetType
            self.serializer = Serializer(for: self.packetType)
            // reference needed so we can update state
            self.controller = controller
            
            super.init()
        }
        
        override func main() {
            let server = TCPServer(
                address: self.controller.address,
                port: self.controller.port)
            
            defer {
                print("Closing down the \(self.packetType) server.")
                server.close()
            }
            
            switch server.listen() {
              case .success:
                let side = self.packetType.rawValue.capitalized
                print("\(side) server listening at \(self.controller.address):\(self.controller.port)!")
                
                while true {
                    // accept() stalls until something connects
                    if let client = server.accept() {
                        // we connected!
                        print("\(self.packetType.rawValue.capitalized) has a new connection!")
                        updateStatus(connected: true)
                        
                        handle(client)
                        
                        // if we're here then we disconnected
                        print("A client disconnected from the \(self.packetType.rawValue) server")
                        updateStatus(connected: false)
                    } else {
                        updateStatus(connected: false)
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
                switch (self.packetType) {
                    case .daq:
                        model.daqSocketConnected = connected
                    case .lord:
                        model.lordSocketConnected = connected
                    case .phone: ()
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
                    switch self.controller.packetType {
                        case .daq:
                            let json = Coder().decode(
                                from: Data(content_b),
                                ofType: Coder.DAQPacket.self)
                            // preview parsed data
                            print(Coder().encode(from: json))
                            
                            // since changing the model updates the UI, we have to make updates on the main thread.
                            // this will update as soon as the main thread is able.
                            DispatchQueue.main.async {
                                if let power = json.voltage {
                                    self.controller.model.power = power
                                }
                            }
                            
                            // defer file-writing to be async
                            DispatchQueue.global().async {
                                self.serializer.serialize(data: json)
                            }
                        
                        case .lord:
                            let json = Coder().decode(
                                from: Data(content_b),
                                ofType: Coder.LordPacket.self)
                            // preview parsed data
                            print(Coder().encode(from: json))
                        
                            // use speed from lord since we killed the RPM magnets :(
                            DispatchQueue.main.async {
                                // replace with phone speed if this fails
                                if let speed = json.groundSpeed {
                                    self.controller.model.speed = speed
                                }
                            }
                        
                        if let speed = json.groundSpeed {
                            updateLiveTimingDash(at: "updateRtkData", with: "{\"speed\":\(speed)}")
                        }
                        
                            // save to file
                            DispatchQueue.global().async {
                                self.serializer.serialize(data: json)
                            }
                        
                    // should never happen
                    case .phone: ()
                    }
                }
            }
        }
    
        private func updateLiveTimingDash(at endpoint: String, with string: String) {
            // see https://stackoverflow.com/a/26365148
            var request = URLRequest(url: URL(string: "https://live-timing-dash.herokuapp.com/\(endpoint)")!)
            request.setValue("application/json", forHTTPHeaderField: "Content-Type")
            request.httpMethod = "POST"
            request.httpBody = string.data(using: .utf8)
            
            print(request)
            
            let task = URLSession.shared.dataTask(with: request) { data, response, error in
                guard
                    let data = data,
                    let response = response as? HTTPURLResponse,
                    error == nil
                else {
                    print("error", error ?? URLError(.badServerResponse))
                    return
                }
                
                // check for http errors
                guard (200 ... 299) ~= response.statusCode else {
                    print("statusCode should be 2xx, but is \(response.statusCode)")
                    print("response = \(response)")
                    return
                }
                
                // do whatever you want with the `data`, e.g.:
                print(String(data: data, encoding: .utf8)!)
            }
            
            task.resume()
        }
    }
}
