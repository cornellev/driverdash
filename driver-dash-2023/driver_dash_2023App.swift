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
        // see https://github.com/httpswift/swifter
        let server = HttpServer()
        server["/hello"] = { .ok(.htmlBody("You asked for \($0)")) }
        server["/websocket-echo"] = websocket(
            text: { session, text in session.writeText("echo:" + text) },
            binary: { session, binary in session.writeBinary(binary) })

        do {
            try server.start(8080)
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
