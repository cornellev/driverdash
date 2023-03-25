//
//  DriverDashApp.swift
//  driver-dash-2023
//
//  Created by Jason Klein on 3/24/23.
//

import SwiftUI
import Swifter

// todo: get the proper format from Ari
struct Packet: Codable {
    enum Variable: String, Codable {
        case speed, power
    }
    
    let type: Variable
    let data: Double
}

class DriverDashAppModel: NSObject, ObservableObject {
    @Published var speed = 0.0
    @Published var power = 0.0
    private var server: HttpServer!
    
    override init() {
        super.init()
        
        // see https://github.com/httpswift/swifter
        self.server = HttpServer()
        
        // make it easy to check whether the server is alive
        server["/ping"] = { request in return .ok(.text("pong")) }
        
        // handle websocket connections. Assumes everything is JSON
        server["/websocket-echo"] = websocket(text: { session, text in
            // see https://stackoverflow.com/a/53569348 and also
            // https://www.avanderlee.com/swift/json-parsing-decoding/ for JSON decoding
            let json = try! JSONDecoder().decode(Packet.self, from: text.data(using: .utf8)!)
            
            switch json.type {
            case .power:
                // see https://stackoverflow.com/a/74318451
                DispatchQueue.main.async {
                    self.power = json.data
                }
                
            case .speed:
                DispatchQueue.main.async {
                    self.speed = json.data
                }
            }
            
            print(self.power, self.speed, json.data)
            session.writeText("Got it thanks.")
        })

        do {
            try server.start(8080)
            try print(server.port())

        // https://stackoverflow.com/a/30720807
        } catch let error {
            print(error.localizedDescription)
        }
    }
}

@main
struct DriverDashApp: App {
    @ObservedObject private var model = DriverDashAppModel()
    
    var body: some Scene {
        WindowGroup {
            HStack {
                VStack {
                    DataView(title: "Speed", units: "km/h")
                    Text("\(model.speed)")
                }
                DataView(title: "Power", units: "????")
            }.padding()
        }
    }
}
