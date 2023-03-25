//
//  driver_dash_2023App.swift
//  driver-dash-2023
//
//  Created by Jason Klein on 3/24/23.
//

import SwiftUI
import Swifter

@main
struct driver_dash_2023App: App {
    
    init() {
        let server = HttpServer()
        server["/hello"] = { .ok(.htmlBody("You asked for \($0)"))  }

        do {
            try server.start(8080)
            print(server.listenAddressIPv4 ?? "no IPv4 address")
            print(server.listenAddressIPv6 ?? "no IPv6 address")
            try print(server.port())
        // https://stackoverflow.com/a/30720807
        } catch let error {
            print(error.localizedDescription)
        }
    }
    
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}
